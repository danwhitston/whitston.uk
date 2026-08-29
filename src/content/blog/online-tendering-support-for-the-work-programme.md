---
title: "Online tendering support for the Work Programme"
description: "Breaking Work Programme bid support into five distinct areas, and working out which of them online tooling could actually help with."
pubDate: 2010-10-30
---
After finding out a bit more about Merlin's web portal earlier this week, I've been thinking about online tendering support. Roughly speaking, bidding can be split into five areas:

- Bid management
- Service design & research
- Partnerships
- Financials
- Bid writing

Of these, the only one that's really worth getting into at this stage as a web application is supporting partnerships. I'd suggest two dashboards, one for users with potential primes and one for users with potential subcontractors. I'm not sure if an administrative dashboard would be needed as I suspect whatever's necessary will already be possible through existing management tools on the software. The initial stage and overall management of the status of potential subcontractors are both potentially useful, but managing and supporting the detailed negotiations around price and the like would add more complexity than it removed.

## Primes sign-up

- Primes would need to be signed up manually, probably by us following a conversation with each prime, possibly through a sign-up form on the site or a sign-up link in a mass email / news story elsewhere
- Both primes and subcontractors (note that I'm normally using these words interchangeably to mean both entire organisations and individual users in these organisations) should have a multiple user setup, with one user acting as the 'owner' of the organisation with the power to create and delete other users, and the ability to transfer ownership of the organisation to another user
- Sign-up information doesn't need to be particularly major, given anything important can likely be scraped in from Merlin - primarily the areas that primes are bidding in

## Subcontractors sign-up

- Sign-up of subcontractors can happen either through a sign-up form on the site, or through manual creation by an administrator, or through creation / upload by a prime, or through automated sign-up following receipt of an emailed expression of interest from the Merlin portal
- It is assumed that initial sign-up will be for the purpose of applying to a single prime. This depends on the approach taken by the Merlin portal, but in any case there is a strong chance that a subcontractor will apply to multiple primes through various routes. This means that 'sign-ups' that turn out to be for a subcontractor who's already signed up (i.e. their email address is already a user on the system) should be redirected as applications to the prime in question, without forcing a re-sign-up
- The subcontractor sign-up process should where necessary include entry of any information normally found in the Merlin standard EoI template, to make sure all subcontractors have the same basic information available

## Primes dashboard

- Standard view is 'Current applications', which shows all current applications. It is possible to change the status and ownership of any application, either individually or in bulk. It is possible to filter applications by status and by the responses to the filter questionnaire. By default applications are filtered to only show the current user's, unset or orphaned ones. This can be unfiltered to allow the user to see and take over applications belonging to other users in the organisation. Roughly speaking, the system has a certain amount in common with an issue tracker system
- There are two possible ways of handling filter questionnaires. One is a simple 'standard filter' approach where every supplier to a particular prime is automatically sent the standard filter questionnaire for that organisation. The other is a more powerful approach where users can create and edit a range of questionnaires, and assign questionnaires to individual suppliers depending on suitability. The simpler approach may be better for now. The actual process of creating the questionnaire needs to be made as painless as possible, and should allow for radio buttons, checkboxes, numerical and text answers
- The 'owner' of the prime additionally needs a user management pane to add and remove users to the prime. When a user is removed, the applications assigned to them are set to 'orphaned', but their status is left unchanged
- The possible statuses of applications are awaiting filter questionnaire, questionnaire completed, active, rejected, subcontract offered, subcontract signed. Awaiting filter questionnaire (which is the initial status, unless there is no questionnaire in which case the status skips straight to active) and 'rejected' are the only ones of these that needs to trigger an email to the subcontractor. Both the subcontractor and the prime can safely see the same status. Both of the triggered emails should ideally be customisable templates
- Simple export to CSV of the current view is vital, and the email address of the relevant user for each application should be displayed in the table to assist both in messaging the users (use a mailto link?) and in making user of the CSV data. It's probably best not to handle messaging between primes and subs internally on the system at present. Hence the mailto links and ease of export
- There should be a link somewhere on the screen to a display of other potential subcontractors on the system who meet the prime's criteria (currently, just for location, until we know what the taxonomy is for Merlin) and allowing the prime to invite them to express an interest in working together. Again, depending on taxonomy, this would likely mean creating a filterable list with checkboxes and a customisable message template to be sent to potential subs
- For the filter questionnaires stage, it may be desirable to have a cut-off date, by which all EoIs and questionnaires must be submitted. Applications received after this date could be filed in the applications view as 'too late' and generate a customisable but automated 'you're probably too late' style response

## Subcontractors dashboard

- There should be an alert at the top about uncompleted applications
- The main view should be 'Current applications', showing applications to primes, with filtering capability by status, and automatic but changeable filtering to those applications owned by the current user or set to 'unset' or 'orphaned'. Pending questionnaires should normally appear at the top, and rejected applications at the bottom
- User management pane similar to that for primes
- Ability to change 'owner' of an application, to complete and submit a questionnaire, to view completed questionnaires. It would ideally be very easy to extract data from completed questionnaires and paste it into new ones where the questions are the same. As an aside, it would be lovely but impractical to enable aggregation of questions from many primes into 'answer just the once' forms, at least without a very engaged and active collator willing to negotiate with each prime
- There should be a link to potential primes that match the subcontractors taxonomy etc. same as with primes, and allowing the subcontractor to apply to them also. There may need to be some thought about informing primes of this, but there's really very little advantage to primes in pretending that other primes don't exist and that subcontractors won't contact them
- Export to CSV, probably some kind of mailto links again
- Email automated reminders to users as the cut-off for questionnaires approaches?

This is a first sketch of a proposed solution.

Note: This is both part of my ongoing quest to drown the world in bullet points and taken fairly directly from an outline proposal elsewhere.

---

*Originally published at `https://danieljohnston.co.uk/2010/10/30/online-tendering-support-work-programme` on October 30, 2010.*
