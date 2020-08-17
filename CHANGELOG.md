# [2.6.5-Beta R1] June 5, 2020

Major note, ads removed. They were slowing the app down way too much. If a page needed to load but had an ad, the ad loads first!
Crazy stuff, ads are gone.

- Removal of Ads.
- Links in comments work.
- UI tweaks
- Testing new font system, privately. In the near future there will be a setting allowing you to change fonts in settings.

# [2.6.5] May 26, 2020

Is that a 5? Have we broken from the endless 2.6.4 pushes? Yes indeed we have.
2.6.5 will add some new features and improve core functionality. But whats in this release.

 - Major navigation overhaul under the hood. Navigation should be way snappier
 - Memory management improvements. Less of a RAM hog as stale pages (and their resource heavy images) will now either be stored in Cache temporarily or destroyed. But what they won't do is linger in RAM. Deciding the fate of stale resources is determined by available RAM on the device and available CPU cores.
 - There's a new initial optimizer in town. On your first launch (or if you never adjusted performance options). The Optimizer will change some settings around for better performance for your hardware.
 - Upstream updates.
 > Expect UI redesigns for Tag view, Users view (non-existent right now), and the pool screen (yes, again)


# [2.6.4-Hotfix 6] May 19, 2020

This update fixes a bug.

 - Suggested tags for search are actually populated.
 - Upstream updates.


# [2.6.4-Hotfix 5] May 18, 2020

This update is nothing but performance improvements.

 - Pool Thumbnail storage fix.
 - Pool Thumbnail image get optimized, should be leagues faster.
 - Introduction of improved storage system, only active in pools for now but will be rolled out overtime once a migration solution can be created for them.
 - Upstream updates.

# [2.6.4-Hotfix 4] May 14, 2020

This update is nothing but performance improvements.

 - Navigation refinement, resolves issue where closed pages stick around in memory.
 - Fixed issue where network on an activity is closed too aggressively on a page, meaning active pages can end up with no network access.
 - Settings Cache fixes.
 - Upstream updates.

# [2.6.4-Hotfix 3] May 9, 2020

This update along with the usual round of performance gains includes UI redesign work.

 - Pool Search interface redesigned.
 - Favorites menu reunified UI.
 - Further UI unification, bringing the old in line with the new in too many small places to note.
 - Upstream updates.

# [2.6.4-Hotfix 2] April 29, 2020

This update includes some bug-fixes, new default settings, and performance tweaks.

 - Under the hood performance tweaks.
 - New default settings under performance.
 - Further UI unification, bringing the old in line with the new.
 - Upstream updates.


# [2.6.4-Hotfix] April 24, 2020

This update includes some bug-fixes. Nothing to write home about.

 - Pages in the background now actually stop hogging bandwidth.
 - Image quality preferences are reflected on HomePage.
 - Image Loading system has had a performance tuneup.
 - Upstream updates.

# [2.6.4] April 15, 2020

This update includes the **New Home Screen**, Revitalization of the Recommendation System, And a Whats New prompt for future version updates!

### Features:

 - Recommendations based on recent favorites
 - Overhauled Video Systems
 - Temporary Blacklist Toggling in Pools
 - Smarter Recommendations. (You probably didn't experience it before, but trust me on this one)
 - Better Cache Logic
 - Redesigned Home Screen with additional features after login.
 - More Robust Favorites / Blacklist / Likes Syncing.
 - UI improvements.
 - URL Parsing for comments and Descriptions. Pretty much hyperlinks.
 - UI scaling glitch fixed
 - Better Memory Management results in more pages in history before their cleared
 - Better notification system to keep you informed on what the app is doing.
 - Performance gains as per usual
 - The usual bug fixes

# March 16, 2020

Afraid you won't be heard? Commenting and Voting has been added.

### Features:

 - Commenting is available [After Login]
 - Voting [After Login]

## March 7, 2020:
* Login is available, on the beta channel. Blacklist sync is disabled, as its new endpoint is still a mystery.
## March 6, 2020 (Later that day):
* Comments restored with some Voodoo hack and slash nonsense.
* Forced Blacklist managed.
## March 6, 2020:
* Survived the great API apocalypse of 2020.
* Comments are unavailable as the endpoint to reach them is MIA.
* Login is disabled as its currently undocumented. For what we use it for (blacklist, favorites, and comments)
## March 4, 2020:
* Login Support!
* Allows syncing for favorites and blacklist; though the old e621 API (new one might fix this) doesn't seem to have a way to update the blacklist, just read from it, so blacklist is one way, we can get your blacklist and you can add more in the app, but anything added in the app won't make its way to your account.
* Comic mode! Its fancy, long-press on nearly any image (not icon images) and you'll be put in the new comic reader mode, it allows you to quickly swipe through full-sized images. It's designed mainly for pools, so there's an icon to launch it directly inside pools, but it can be initiated in most places. Easter Egg: Including the posts children's slider

## February 15, 2020:
* Recommendation scores default to off now.
* UI improvements
* Yet more speed enhancements.

## January 31, 2020:
* Oh where to begin...
* Bug fixes.
* Recommendation scores added to posts.
* Performance improvements to post get systems.
* Trending page (home) updated to not rebuild every single time you jump back to it.
* Trending page default carousel updated to less computationally expensive version.
* Restored, loading preview image (somewhere along the line it was disabled).
* A slew of new settings.
## January 7, 2020:
* Bug fixes.

## January 5, 2020:
* Bug fixes.
* Language support experiment. (German & Spanish)

## January 3, 2020:
* UI tweaks for viewing a post. Dropdown menus are added for a cleaner UI.
* A deluge of new setting options for performance/style/ and experiments.
* Speed enhancements.
* No more "No trending" lie, if nothing is trending for today, we'll get yesterdays, or last week, or last month or last, etc.
* Visual indicator for whether you liked a post already. Used to be available in older versions, but was removed until it could be improved to handle 1000+ favorites, ladies and gentlemen we did it... probably, you tell me.

## December 16, 2019:
* UI tweaks, navbar now no longer takes system default color (dark mode / light mode) but instead takes it from the app's settings like everything else. (Changing navbar will require a restart though)
* Optimized greatly search speeds, and pulling posts from memory. (We now load posts so quickly that slow UI updates are not going to stand in the way of you getting yourself throttled from constant requests :P )
* Temporarily shuttered search suggester (the one in fav stats) for public release, It'll be back and better than ever thought! Just you wait.
* And of course PUBLIC RELEASE, we're public now!

## December 14, 2019:
* UI tweaks, cleaned up spacing and fixed Pool screen extending under the visible view.
* Performance Tweaks, less frequent utility function checks, like updating the search bars suggestions. 
* Testing Ad deployment, with the goal being for them to be easily ignorable and fairly unobtrusive.
## December 8, 2019:
* e621 Icon on posts to route you to the e621 link of the post.
* Fancy Trending Cards experiment.
* Smoother scrolling.
* Fixed Video removal issue.
* Disabled ArtistPreview (added extra step to search artist).
* Tapping the icon of the page your on takes you back to that page's "home".
* And tons of bug fixes.
## December 2, 2019:
* UI tweaks.
* Bug smashing.
## December 1, 2019:
* Polish.
* A lot of under the hood tweaks have resulted in a smooth glide, it's faster than its predecessors by nearly 200% (no joke, we measured it) A lot of these changes are upstream from the libraries we use and some from local changes but a win is a win!
* Tiny itty bitty tweaks here and there to the UI so that its not quite so annoying... or just odd.
## November 29, 2019:
* Down with the drawers and up with the navigation bar! A major shift in UI theme has been pushed to cert hopefully making the app more user-friendly.
* New Navbar
* Removed Drawer
* Better Theme management
* Exit paths on all pages.
* Less reloading == better data rates and a faster app.
## November 26, 2019:
The Water rises, Pool Search has been added. No running!
* Long Pressing on images in their search pane and certain other areas <.< will allow you to scroll left to right to other posts. Added mainly because scrolling through comics the old way is jarring.
## November 25, 2019:
(affects carnival barker voice) ~Ahem~
* We've got Trending cards.
* We've got recent Activity Sliders.
* We've got a smarter filter.
* We've got speed enhancements.
* (Work has begun on Pool searching)
## November 23, 2019:
* Children & Parent Post parsing.
## November 18, 2019:
* Suggestions? A mysterious suggestion bar will show up on the post search page sometimes suggesting tags to add to your search.[spoiler] Not much of a mystery, it generates suggestions based on your searches during your current session, future iterations will take into account your favorites as well.[/spoiler]
## November 16, 2019:
* Better back logic, to solve memory clogging issues.
* Added fav-count to search page.
* Added setting to toggle off the above new feature.
# -- Open Beta Begins --

## November 15:
* Added tag recommender (It's in Favorites > Stats)
## November 13, 2019:
* Added Artist Spotlight test UI.
## November 12, 2019:
* QoL improvements.
## November 11, 2019:
* Orientation Support, landscape should take advantage of the new screen position... right?
## November 10, 2019:
* Favorites are now preserved locally.
## November 6, 2019:
* Massive UI overhaul and reinforcing backend logic.
## October 28, 2019:
* Changed timestamp to the difference from now.
## October 27, 2019:
* Date Timestamps on search page
## October 25, 2019:
* Block SWF (Flash) content.
## October 21, 2019:
* Cache all the things.
## October 20, 2019:
* Improved request logic to adhere to best practices for e621 API
## October 18, 2019:
* Icon
