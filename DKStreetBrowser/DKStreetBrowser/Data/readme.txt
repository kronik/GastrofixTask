We would like you to implement small application. In the attachment you can find 055759_2012-07-20_09-40_.csv which contains list of the streets presented on the map 055759_2012-07-20_09-40_.png. 

Create small application which will displays the list of the streets and a map in a second view. Here are some points which should be fulfill.

Craete an object which will be the street object. Object should contain:

1. the id of the street ( NSInteger value), which determine the order of the street in the list sorted alphabetically, 
2. street name, 
3. map index ( A-Z, 1-27) loaded from csv file.

User interface and functionality:

1. First view should display the list of the street names loaded from the csv file. Items on the list should be loaded asynchronously and the list should be sorted alphabetically. At the top of the list there should be a search field which should allow filtering the list. List should be similar to the list of contacts from native iPhone app. Items should be grouped in sections by the first letter of the street name and index with the letters should be presented on the right site of the screen.

First row of the item cell should present street name
Second row of the item cell should present: on the left site: id of this street ( id of the street) on the right site: index from the map

For example:
-------------------------------
Saint Marys Avenue 
580			P-15
-------------------------------

2. Second view should present the map. It should be possible to zoom in and zoom out a map. 

3. User should be able to select one street from the list. Then second screen should be opened, zoom in and present particular part of the map.