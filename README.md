# Project 2 - Flix

Flix is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: **30** hours spent in total

## User Stories

The following **required** functionality is complete:

- [x] User can view a list of movies currently playing in theaters from The Movie Database.
- [x] Poster images are loaded using the UIImageView category in the AFNetworking library.
- [x] User sees a loading state while waiting for the movies API.
- [x] User can pull to refresh the movie list.

The following **optional** features are implemented:

- [x] User sees an error message when there's a networking error.
- [x] Movies are displayed using a CollectionView instead of a TableView.
- [x] User can search for a movie.
- [x] All images fade in as they are loading.
- [x] Customize the UI.

The following **additional** features are implemented:

- [x] List anything else that you can get done to improve the app functionality!
- Added details page (Image, Title, Release Date)
- Scrolling feature added to Details Page
- Added Tab feature (Top-Rated, Now Playing, Upcoming)
- Customized navigation bar
- Customed selection cell
- Changed flow layout

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. Link to fandango or another movie ticket buying website.
2. Allow the user to rate the movie, and then store in a database or possibly share with an existing database (such as RottenTomatoes)

## Video Walkthrough

Here's a walkthrough of implemented user stories:

Network Error:
<a href="http://imgur.com/xNSoXAu"><img src="http://imgur.com/xNSoXAu.gif" title="source: imgur.com" /></a>

App Demo:
<a href="http://imgur.com/xNSoXAu"><img src="http://imgur.com/xNSoXAu.gif" title="source: imgur.com" /></a>


GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app.
- It took me a while to figure out how to display the "Networking Label Error" -> I had it on the Table View instead of over it
- Converting from the table view to the collection view was challenging. Modifying the flow layout was also challenging.
- The search bar was tricky at first. When I was in table view, I used "tableView.tableHeaderView", but when I changed to Collection View I couldn't use that method anymore.
- Attempted to include both a table and a collection view, but ran into trouble with the search bar/got errors
- Making the images fade in was also tricky. I had to watch a lot of youtube videos/tutorials :)

## Credits

List an 3rd party libraries, icons, graphics, or other assets you used in your app.

- [AFNetworking](https://github.com/AFNetworking/AFNetworking) - networking task library
- [MBProgressHUD] - loading symbol

## License

    Copyright [2016] [Meena Sengottuvelu]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
