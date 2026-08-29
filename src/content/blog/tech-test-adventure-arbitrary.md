---
title: "Tech test adventure: Arbitrary discount rules and the strategy pattern"
description: "Taking the Gilded Rose kata further than the brief asked, and using the strategy pattern to model arbitrary, composable pricing rules."
pubDate: 2017-05-17
---
## Part 1 - The Gilded Rose

A couple of months back, I took on the [Gilded Rose kata](https://github.com/emilybache/GildedRose-Refactoring-Kata). In that test, you're given a small piece of legacy code with lots of nested conditionals, which causes the stock of a fantasy tavern to change in quality and sale price as each day passes. The task is to refactor the code and add a new rule, without changing any of the existing functionality.

Never one to take the easy route, I really wanted to find a way to represent the various rules governing the decay and change in price over time in a way that separated them out from each other, without hardcoding the specific rules in the structure. I wanted the solution to be applicable regardless of the implemented rules, and to play nicely with large numbers of interacting rules.

This was somewhat outside of the original spec, but is a common issue in the 'real life' situation that the spec was modelling - almost any role-playing game has to grapple with issues of emergent interaction between different effects and characteristics. It was also an interesting technical challenge.

The thing I was trying to do was to iterate through each rule in turn, starting with the current age and quality score, testing if the rule applied, applying the rule to change the age and quality if so, then passing the new age and quality to the next rule.

My [attempt at a solution to the Gilded Rose](https://github.com/DanielJohnston/GildedRose-Refactoring-Kata/tree/master/ruby) worked just fine, but the abstraction to a model was messy, and the rules code was almost less readable than the original. In discussion with the person setting the test, I was pointed to the [strategy pattern](https://en.wikipedia.org/wiki/Strategy_pattern).

The strategy pattern codifies a structure for swapping out methods on the same base object class, which gives an elegant way of using the same information, structure and base code, while individualising the operation of rules (such as, say, #applies? and #update_quality and #update_age).

## Part 2 - A range of discount rules

Cut to last week. I was set the task of [creating a product order process](https://github.com/DanielJohnston/techtest-honeycomb). Most of it was straightforward, and I've implemented and worked with ecommerce systems enough that I had a good idea of what the eventual structure would look like.

However, the meat of the test was giving salespeople the ability to try out different discounts on orders. A couple of discounts were specified, but the door was open to more being added. The existing discount rules acted on the order total, the quantity of specific order types, and reduced prices of specific order types or added a %discount to the entire order. Further, the rules could interact such that the order they were applied in affected the final price. A %discount to the entire order should only be applied at the end, for example.

This means that the solution needed to:

- Enable discount rules to 'see' and affect elements of an order and the total
- Make it easy to add new rules without refactoring existing ones
- Make it possible to choose which discounts to apply to an order
- Apply selected rules in a pre-set order to prevent incorrect application

Applying the same steps but with differing rule contents each time? With a selected set of rules for each order? Sounds like it's time to bust out the strategy pattern! (With a side order of builder pattern!)

### Poking the bear

I used a TDD approach, going from feature test to unit test to class and method definition. My initial focus was on getting the basic order functionality right , extracting classes as necessary to maintain separation of concerns.

However, I didn't immediately see a good way to start moving forward on creating a list of discounts, then applying them using the strategy pattern. I used a [#discount_total method within the order](https://github.com/DanielJohnston/techtest-honeycomb/blob/20d0d42032d0160ee547bc09d4174f6aed818fbb/lib/order.rb) as an immediate solution, with the intention of extracting and abstracting later, once the rest of the structure was in place.

### Rousing the bear

Within fairly short order, I had [working code](https://github.com/DanielJohnston/techtest-honeycomb/tree/20d0d42032d0160ee547bc09d4174f6aed818fbb), that met the feature tests defined by the spec. Two issues, though:

- The solution as-was didn't allow for selective application of discounts
- Discounts were applied by a lump of code in the Order class, which didn't smell right and didn't bode well for adding further discounts

Definitely time to try that strategy pattern, then. I extracted out the discount code to its own class as a prelude; test-driven of course. Then I created a DiscountList class to hold each discount, and at the same time used the strategy pattern to split each discount rule into a separate class that got injected into the Discount class at time of instantiation. Then it got ugly.

The quantity and complexity of code changes led to substantial changes in the codebase throughout the chain of classes. This backdrop of complexity didn't mesh terribly well with figuring out how to pass objects through the chain of classes and instances. In order to do their jobs, the discount rules needed access to details on deliveries and prices, and to a running subtotal as each discount was applied in turn. The easiest place to put the code to pass this information, and iterate through each discount rule, turned out to be… back in the Order class.

This meant that [the eventual solution](https://github.com/DanielJohnston/techtest-honeycomb) still entailed running a lump of code in the main ordering class, and passing objects in and out of methods in ways that were far from elegant. The lack of storage within the Discount class raises questions as to whether it's a true implementation of the strategy pattern, and likewise with the builder pattern and the various container classes' inability to add contents through composition.

On the plus side, the solution did make it possible to cleanly add further discounts, and to apply them selectively to individual orders, so the intent of the specification was met. While a pre-set order of applying discounts is still pending, it's not difficult to add, and will only cause problems if an operator specifically applies the discounts the wrong way round.

### Better bear waking methods?

There's room to extract the code from the existing solution into a further class, such as OrderLine or perhaps the existing DiscountList. I'm uncertain as to a couple of things, though:

- Is there a better way of structuring this solution, perhaps injecting DeliveryList instances into Discount or DiscountLine instances at time of creation, so they don't have to be passed back and forth as method arguments each time?
- Is there a better way of TDDing this solution? Creating each class was simple enough using unit testing, but the stage where I pulled the discounts, discount_list, and order together was not pretty. I had to rely on the feature tests a lot to make it through that, to the extent that I managed to miss out on unit tests to TDD a method in the Order class, at first.

Suggestions and comments welcome. I deliberately haven't attempted to find an equivalent to this tech test elsewhere yet, but I suspect it's actually a pretty unusual one.

## Part 3 - The Wrong Bear

After posting the first two sections, I interviewed with the organisation who set the test. A simple request, 'make a discount that discounts the total by 20% in July for sales over £30', blew up my approach. To implement this new discount, I needed to both implement a new strategy and add an exclusion to an existing one, the 'default' 10% discount on an order above £30, so that the new discount acted in place of that one. This proves there isn't a separation of concerns. It would be easy to find more discounts that interacted with each other in various similar ways, each one leading to more code complexity to make up for the separate patterns.

I was left with a few unappetising options for the immediate requirement:

1. Create a new strategy as its own class, and modify the affected strategy so that it wasn't applicable in July while the new one was
1. Add the July strategy into the existing discount total by 10% strategy, using an if-then-else structure to change what happened. The name returned by the discount would also need to change (!)
1. Add some kind of selection rules above the strategies, undermining the point of using a strategy pattern in the first place

I went with the first option, as a way of attempting to preserve the intention behind the strategy pattern, and it worked out precisely as badly as I'd suspected. The strategy pattern turned out to be a millstone that multiplied the amount of work with each interaction.

The underlying issue is that I'd assumed that manual selection of discounts, a pre-set order of applying discounts, and a running subtotal, would be enough information to manage interaction between discounts. I'd neglected to consider that new discounts might need to supplant existing discounts in certain situations. I'd also assumed that salespeople would be choosing discounts on an individual basis for customers, rather than setting up rules for selecting which discounts to apply when.

The interviewer suggested that moving toward a YAML file with discounts set up using a simple ruleset on pre-defined types of discount was the appropriate way forward. I've set up simple workflow-style parsers before, and will update this post as and when I switch to that approach. It may be easiest to TDD in this direction by using the second development option from the above list, that of varying rules within each 'strategy', and then transitioning the strategies to a new role as template rules.

It's mildly embarrassing theming a post around usage of a pattern and then being shown that it's not appropriate for the chosen example. It's also a valuable experience in its own right. I've left the previous text as-is; a useful reminder of the dangers of being too gung-ho with a beautiful solution that doesn't quite match the problem.

**Update 20/5** - I've updated the repo with the interview requirement using the second approach. Holding off on YAML until I get a bit more time, and also to think about how to deal with an if-then-else structure with a range of possible conditions.

## Bonus video

The Gilded Rose is open to a huge range of 'solutions'. The following video of a Gilded Kata refactoring in Ruby, by Sandi Metz, walks through a solution that's both elegant and fun to watch:

<div class="videowrapper"><iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/8bZh5LMaSmE" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div>

## Bonus legacy refactoring note

I was really proud of something I did at the start of the Gilded Rose. I wrote a [small piece of code](https://github.com/DanielJohnston/GildedRose-Refactoring-Kata/blob/master/ruby/generate_data.rb) which ran against the existing code base and generated hundreds of test specs, covering the changes over time to each type of item in the tavern stores. This made it trivial to check that later refactoring didn't introduce any regressions in behaviour.

Unfortunately, the [conformance testing code](https://github.com/DanielJohnston/GildedRose-Refactoring-Kata/blob/master/ruby/gilded_rose_conformance_spec.rb) wasn't well structured at the time of submission, and reached a level of complexity that called for its own tests! I'd not really intended it to be the 'body' of the solution, as it was more of a bonus check, but it was rightly considered as part of the overall result. It introduced a level of complexity that was seen as exceeding that required by the test spec. Can't win them all the time, I guess!

---

*Originally published at <https://medium.com/@danwhitston/tech-test-adventure-arbitrary-discount-rules-and-the-strategy-pattern-4675d590036e> on May 17, 2017.*
