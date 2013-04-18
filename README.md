<!---
todo: 
-->

# MYZSQLExplorer

MYZSQLExplorer lets you browse Core Data sqlite stores on your iOS device, or in the simulator running on your MAC. You should have the model file (.mom) in addition to the sqlite file.

This can help during the Development and Testing phases. It can also help in diagnosing problems when already in Production.

You can include the classes in your project and call SQL Explorer from your code, or you can run the sample application and "Open In..." your sqlite store with it (see below).

The source code is available on [github](https://github.com/meizy/MYZSQLExplorer)

## What You Get Is What You See

SQL Explorer displays the following:

- A list of Stores in the selected directory
- The Metadata for the selected store
- The Entity Types in the selected store
- The Object Instances of the selected entity
- The Properties and their Values for the selected object
- The Relations you can follow for the selected object
- The Related Objects for the selected object/relation

## Using the SQL Explorer app

The Sample app allows you to choose a folder in which sqlite stores will be searched. You can also explore stores located inside the app bundle. The app comes with a sample database inside the app bundle that you can explore to for your pleasure...

You can put the model and sqlite files in the app Documents directory using iTunes File Sharing. If running in the simulator, just copy the files to the app Documents folder in the file system.

In addition, The SQL Explorer app registers itself as a File Handler for `.sqlite` and `.mom` files, so you can email yourself the files as attachments and the open them with SQL Explorer. First you need to open the model file (.mom) - SQL Explorer will just save it. Then you open the sqlite file and SQL Explorer will display its contents.

Note: when opened as attachments, the files are saved inside a directory named Inbox, under Documents.

## Including SQL Explorer in my app

Just copy the classes in the `MYZSQLExplorer` directory to your project.

You can call SQL Explorer using one of the following init methods:

init with a store URL:

    - (id)initWithStore:(NSURL *)url;

init with a directory URL:

    - (id)initWithDirectory:(NSURL *)url;

init with a Managed Object Context you already initialized:

    - (id)initWithContext:(NSManagedObjectContext *)context;

## The Model file (.mom)

A matching model file must be available to SQL Explorer in order to explore a store. If a versioned model is used, be sure to provide the right `.mom` file. These files reside inside the `.momd` directory, within the app package.

For each store processed, the model file is searched in this order:

- same directory and same name as the sqlite store (with the `.mom` extension instead `.sqlite`)
- same directory, a `.mom` file by any name
- the `Documents` directory, a `.mom` file by any name
- inside the app bundle, a `.mom` file by any name

## Formatting

If the object has a `name` key - SQL Explorer will consider this to be the object name (duh...)
Be default, SQL Explorer shows the `objectID` value as the object details.

You can enhance this by implementing the delegate method:

    - (NSNumber *) configureCell:(UITableViewCell *)cell withObject:(NSManagedObject *)object;

The return value should be `@YES` if the delegate method handled the formatting or `@NO` if not, in whichg case SQLK Explorer will format the values as best it can.

When showing property values, SQL Explorer performs basic formatting according to the property type as specified in the model.

## Sorting

When displaying objects, SQL Explorer must have a sort key by which to sort them. The sort key is determined in the following order:

- the value returned by the delegate method, if implemented:

        - (NSString *) sortKeyForEntity:(NSString *) entityName;

- the `defaultSortKey` property of `MYZManagedStoreController`
- the `name` property, if the object has one
- the `order` property, if the object has one
- a random property, when none of the above is available


## Limitations

SQL Explorer supports the most common Core Data constructs, but there are some holes, including:

- Fetched Properties
- Configurations and multi-Store models - but you can create the context yourself and init SQL Explorer with the context


## Tips

- If the values are too long to be displayed in the row, you can:
 - switch to Landscape Mode
 - a Long Press on any row will show its detail text in a pop-up window.

## Environment

- SQL Explorer was tested on iOS 5.1 and 6.
- It runs on your iOS device, or in your simulator.
- Portrait and Lanscape orientations

## The License

Copyright (c) 2012-2013:  
Moshe Meiseles  
All rights reserved.

It is appreciated but not required that you give credit to Moshe Meiseles as the original author of this code.
You can give credit in a blog post, a tweet or on a info page of your app. 
Also, the original author will appreciate letting him know if you use this code.

The above copyright notice and this permission notice shall be included in all copies 
or substantial portions of the Software.

This code is licensed under the BSD license that is available at: <http://www.opensource.org/licenses/bsd-license.php>