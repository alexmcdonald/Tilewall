# Tile Wall

## What Is It?

Tile Wall is a super-flexible, easy to configure Lightning Component to display Salesforce records as a series of tiles.  It can be instantly added to any Lightning pages including communities, and works fine in the Salesforce app.

## How Flexible?

* Present any Salesforce Object
* Works in Lightning and in Experience Cloud - including LWR
* Display any fields from the record or a related record, either as fields or as badges
* Endless formatting choices:
 * Component Level:
  * Number of columns
  * Maximum number of displayed records
  * Title
  * Icon
  * Ordering
  * Search Option and Search Text
  * Background Color
  * Field Style: Horizontal (Label to the left) or Stacked (Label on top)
 * Tile-Level:
  * Tile icon/media - hard-coded or based on record fields
  * Background colors - hard-coded or based on record fields
  * Background images - hard-coded or bsaed on record fields
  * Card Title - Field, Text Size, Alignment, Case
 * Field-Level:
  * Display as a Field or a Badge
  * Custom Labels (or no labels)
  * Colour & Background Color - hard-coded or based on record fields
  * Size, Alignment, Case
* Enable actions from each tile by launching Flows
* Easy, re-usable configuration with a flow-based configurator
* Plus, tweak the record set by optionally adding a SOQL Where clause when you drag the component onto a page - eg. to scope the component just to children of a particular Account or other record


## And... Introducing **Dynacat**

Dynacat started as a project to create the ultimate filters component.

* Field-Based Filtering
 * Filter By Field:
  * Picklists
  * Multi-Picklists
  * Checkboxes
  * Number (incl Currency & Percent)
  * Date & DateTime
 * Fields can be on the record being filtered, or on any parent record
 * Picklists, Multi-Picklists and Checkboxes can be displayed as Checkboxes, Radio Buttons, Drop-Downs, or Two Column "Dueling Picklists"
 * Number fields are displayed as a two-ended Range slider, with configurable Min and Max values
 * Dater fields are displayed with a From and To date picker
* And, offer nested filtering "product catalog" style with Attributes
 * Attributes are a custom object included in Dynacat that allow you to define a hierarchy of tags that you can apply to any object. Closest analogy is Data Categories in Salesforce Knowledge.
 * Dynacat can display these attributes as nested checkboxes (default), or as Radio Buttons or Drop-Downs, although you lose the ability to nest with the last two.
* Easy, re-usable configuration with a flow-based configurator
* Display the filtered records with Tile Wall, or build your own UI in Lightning Web Components if you're so inclined

# Getting Started

1. Install the component, then open the Tile Wall (Dynacat) App from the App Launcher.
1. Select the Tile Wall Configurator tab, and create a new Configuration.  Hopefully the options are mostly self-explantory, or see below for all the detail and hints & tips.
1. To create filters for the component, head to the Dynacat Configurator and create a new Dynacat deployment.  Set up Sections, Field Filters and/or Attribute Filters as desired.  If using Attributes, first review the section below.
1. Navigate to the page you want to install the component/s on, or start with the Tile Wall Sample page.  Edit the page and click on the Tile Wall component, and enter the name of the Tile Wall configuration and optionally, the Dynacat deployment.  If using Dynacat, click on the Filters component and enter the name of the Dynacat deployment also

# Configuring Tile Wall

Tile Wall is designed to be used in lots of different place within your org, and to allow configurations to be re-used.  So you can create a wall with key information for all cases in your org, and then re-use the same config on your account’s record page to show only cases specific to each account.

The Tile Wall Configurator flow lets you edit an existing wall config, or create a new one.



The name of the config is used to identify which Tile Wall to add to each page, so make sure it's descriptive.  Each config is specific to the object being displayed on the Tile Wall.



The initial config screen is where you can set and edit most of the Tile Wall config options.  Each option should be self-explanatory, or has a help-text bubble.

In the config you can set:

*Wall Title* (optional), and if set, whether to display an *Icon*, and/or the *Record Count* next to the title in the header of the component.  Any of the Lightning Design System Icons can be used, such as standard:case or utility:trail.  Go to https://www.lightningdesignsystem.com/icons/ (or google slds icons) to see them all.

Whether to enable *Search* across all text fields in the record using SOSL, and if so what *Label* to use for the Search box.  NB: Search only works if you've ticked the Allow Search checkbox in your Salesforce object definition.

*Simple Ordering* by one field, or *Advanced Ordering* to enter multiple, comma-separated fields to order on.

The limit of *Displayed Records* on each screen (results are paginated), and the *Number of Columns* to display on Desktop, Tablet and Mobile screen sizes.

The *Background Color* for the Wall itself.

The *Height* to set for each tile.  Generally you would leave this set to Max Row Height, which will automatically make all the tiles in a row the same height, fitting the tile with the longest content.  But, you can also fix the height if you want all the rows to be exactly the same height, or can let each tile fit it's content individually... which looks a bit weird in my opinion.

The field to use as the *Title* for each tile.  And the *Text Size*, *Alignment*, and *Case* of that title.

You can add an *Icon* or an *Image* (URL) to a column on the left of each tile.  These can be hard-coded in the config, or you can specify a field to use on the record - or on a related record. This works well with formula fields - eg. if Case Status is Escalated, then set icon to utility:warning.  If the status is Waiting for Customer, then set icon to utility:pause.  And so on.  You can also hard-code a fall-back icon/image in case the formula field doesn't return a selection.

You can also specify the *Background Color* and/or *Background Image* for each tile.  Again each of these can be hard-coded, or can be set by selecting a field on the record or a related record.  For example, you may want to change the background for a case tile if the related account is designated as High Value.  You would create a formula field on the Case record, or directly on the Account record, to return the background color or background image URL that should be used based on the account's rating.

If you've set background colors and/or images, you may want to adjust the *Background Opacity* (transparency) of the background, from 0 (fully transparent) to 1 (fully solid/opaque).  I find mixing tile backgrounds with Tile Wall backgrounds can make things look a little weird.

You can select the *Field Label Style*.  Labels can either appear to the left of the field's value (Horizontal), or above the value (Stacked).  Stacked can be better if your fields have longer content, or if you're trying to squeeze in more columns.

And, if you set up field background colors (in the next section), then you might also want to select the *Field Padding* option, which adds just a little bit of space around the field labels and values.

After setting all the different options for your wall (*or* just setting the Tile Title and leaving the defaults) you can set up the *Fields* and *Badges* that you want displayed on each tile, and configure any Flow-based *Actions* that you want to be able to launch from the tile's action menu.  Click the Blue Button at the bottom to create your first.



*Create a Field*

You can display any number of fields in each tile. If a record doesn't have a value for a field, then it won't be displayed on that tile.

Start by giving the Field a name so you can identify it down the track (doesn't have to be unique), and specify the *Order* it should be displayed in.  All Fields are displayed in order below the tile's title.

Tip: To make it easier to reorder fields later on, consider skipping a few numbers initially.  eg. I usually order my fields as 10, 20, 30.  If in future I want to add a new field at the start, I can simply order it as anything between 1-10.

Select the *Field* to display from the record or a related record.  And optionally enter a *Label*.  The Label location (above or to the left of) is determined by the *Field Label Style* setting from the previous step.

Set the *Text Size*, *Alignment*, and *Case* for the field's value, as well as it's text color and background color.  You can select record fields (usually formula fields) for both of these for dynamic coloring as well.

If you do specify a Label, then you can also set its color and background color.



*Create a Badge*

You can display any number of Badges in each tile.  If a record doesn't have a value for the specified badge field, then it won't be displayed.

Start by giving the Badge a name and *Order*.  Badges are displayed next to each other in order, below the tile's fields.

Select the *Field* to display from the record or related record.  And optionally enter a *Label*.  Optionally choose an *Icon* and/or *Icon Field* to display on the left of the badge, using the same naming format as for the tile media.

And select the Color and/or Background Color for the Badge.  The dynamic Field-based color choices are very effective here.  For example, you could create a badge to display Case Priority.  The priority can be displayed in white text on a red badge for High or Critical cases, white text on an orange badge for a Medium case, or black text on a pale green badge for Low priority.



*Create an Action*

You can launch any number of Flow-based Actions from each tile.  Actions appear in an Action menu to the right of the tile's title.  Actions are launched in a modal dialog directly from the Tile Wall.

Start by giving the Action a name and *Order*.

Enter the *Flow Name* (API Name) to launch, or specify a field that defines the tile-specific Flow if required.  I haven't thought of a lot of uses for that but I'm sure there's an edge-case somewhere out there!

Set the *Label* for the Action, this will display in the Action Menu.

Optionally, pass three hard-coded values into the Flow to help configure the Flow's behaviour.  The record Id for the tile will automatically be passed into the Flow.  See the section on Flow Actions below for guidance on how to set up your Flows.


# Configuring Dynacat

The idea for Dynacat came from a customer demo.  They needed a way to filter their products on a hierarchy of nested attributes.  For example, one filter was for use cases and sub-use cases grouped by industry - a three-level hierarchy.  With hundreds of different use cases and a desire for suppliers to be able to manage their own metadata, standard options like dependent picklists would be too cumbersome.  Instead, a custom object to store the attribute hierarchy (called Attribute) and another to relate those attributes to the products, gave almost unlimited flexibility.

Over many late nights Dynacat (*Dyna*mic *cat*alog) took shape, adding field-based filtering and support for any Salesforce objects, not just products.  Dynacat is bundled with Tile Wall for a ready to go filtering and record display component, but you can also build your own UI in an LWC to display the filtered records - see the section below if this is important for you.

Dynacat Filters are set up using the Dynacat Configurator screen flow.  If you want to use the nested attribute filters, then you’ll need to set up at least the top-level attribute first in order to select it in the flow.  See the section on Attributes below for instructions.



Similarly to Tile Wall, Dynacat allows you to create multiple different configurations, called Deployments to distinguish them from Tile Wall.

Open the Dynacat Configurator and create a new deployment.



The name of the deployment is used to identify which set of filters to add to each page, so make sure it's descriptive. Each deployment is specific to the object being filtered.



The config at the deployment level is very minimal, most of the options are at the individual field level.

Each filter you configure can have a clear button on it.  You can also add a *Clear All* button at the deployment level.

You can also delete an unwanted deployment, and all its filters, by toggling the *Delete* option and clicking Save.

Click on the blue Create button to create your first filter.



You can create *Sections,* *Field*-based filters, or *Attribute*-based filters.

Specify the order for all the filters (including sections).  As with Tile Wall, it can be handy to initially order in increments of 10, so that you can move or insert new filters down the track.



*Sections* are just headings to separate groups of filters



*Field*-based filters let you filter on most fields on the object, or a related object.  Supported fields are picklists, multi-select picklists, checkboxes, number, currency, percent, date, or date-time.

Select the Field from the drop-down - selecting a lookup or master-detail field will add an additional drop-down for the related object.

Depending on the field-type selected, additional fields may be displayed on the next screen/s.



For picklist and multi-select picklists fields, you can choose how you want the filter to be displayed.  Options are as Checkboxes, Radio Buttons, a picklist (drop-down), or a two-column "dueling picklist".

By default any picklist values for the field will be included, but you can restrict this.  If you do this, enter the *valid picklist values*, comma-separated.



Checkbox fields (in this case the IsEscalated field) have the same display options as picklists, but with only two values.  You can specify the l*abels* for the checked or unchecked options.



For number, currency, or percent fields, the filter will be displayed as a two-ended slider.  You need to set the *minimum* and *maximum* values for the filter, in this case the Account Annual Revenue field.



And Date / Date-Time fields don't have any configuration, they're displayed as two date-pickers, being the start date and end-date for the filter.



*Attribute*-based filters are configured on the one page.  Follow the guidance in the Attributes section below for setting up and assigning attributes to records.

Select the *Top-level Attribute* record to filter on.

Choose how to display the attributes.  If you have nested attributes, then Checkbox is the only option that will display these.

Select the *lookup field* on the Record Attribute object, that relates to the records being filtered.  Sample fields have been created for standard Products, Cases, and the sample Dynacat Product object.  If you're filtering any other object, you'll need to create the lookup field.



The Filters table shows you all the configured filters for your deployment, and lets you *edit* or *delete* them from the action menu.



# Tile Wall & Dynacat Lightning Components

There are two key Lightning Components to enable Tile Wall and Dynacat on a page.  The Tile Wall (with Dynacat) component displays the Tile Wall.  And the Dynacat: Catalog Filters component renders the configured Dynacat filters.

The in-page configuration of both these components is very simple.  For the Dynacat: Catalog Filters component, you simply need to enter the Dynacat deployment name (I don’t think the displayed levels parameter actually does anything at the moment 🤔 but is supposed to limit how many levels of nested checkboxes are expanded when the page first loads)

For the Tile Wall (with Dynacat) component, enter the Tile Wall configuration name, and if you’re using Dynacat, the Dynacat deployment name.  Optionally you can limit the global set of records that will be displayed with a SOQL-formatted Where clause - eg. Status != “Closed” AND Confidential__c = FALSE.  If you are dropping the component onto a Record Page, you can also use the Where clause to scope it to only tiles related to that record.  For example, if you drop a case Tile Wall configuration onto an Account page, you would include AccountId = '{{recordid}}'  in the Where clause.  {{recordid}} will automatically expand into the current record’s Id.

If the Tile Wall component is being used in an Experience Cloud site, an additional attribute is included to pass in the record Id.  This attribute value will default to the standard {!recordId}.  If you are using it on a record page such as an Object Detail page, then leave it as is.  But if you are using the component on a different page, you should blank out the value, or hard-code it if that’s relevant for your use case.


# Attributes

Attribute-based filters are an alternative to field filters, aimed at use cases such as product catalogs or market places where you can have very extensive, and particularly nested checkbox filtering.

To set up attribute-based filters, first create Attribute (Dynacat_Attribute__c) records.  You can relate attributes to each other to create a parent/child hierarchy for nested filtering.  And you can also choose whether the attribute should be selectable (ie. have a checkbox next to it) or or not.

Once you’ve created your attribute tree, the next step is to associate it with the object you’re filtering.  To do this, create a new lookup field on the Record Attribute (Dynacat_Record_Attribute__c) object, with a relationship to the object you’re filtering.  The installed package will include pre-built lookup fields to the Product2 and Case objects, as well as to the custom Dynacat_Product__c object.



Next, edit the Lightning Page for the object you’re filtering, and add the Dynacat: Attribute Selector custom component to it.  Set the Lookup Field Name to the API name of the field you’ve just created.  You can also pre-expand additional levels of nested attributes by adjusting the Intially Expanded Levels field, see the screenshot below for the format.


Now, you can select the attributes that should apply for each record, at any level.  Each associated attribute is created as a Record Attribute record. You can also use data loader to import record attributes against your records en masse if you have more than a few to load.

At this point you can add an Attribute filter to the Dynacat Deployment following the steps above.  For nested filters you need to use the Checkbox Filter Display Type.



# Enabling Access for Experience Cloud Users


TileWall and Dynacat work great in Experience Cloud, both Aura and LWR.  You need to make sure that your user profile (and/or the Guest User Profile for your site for unauthenticated use cases) have access to:
1) The objects you’re displaying/filtering
2) For Attribute-based filters, read-only access to all fields on the Dynacat_Record_Attribute__c and Dynacat_Attribute__c objects
3) Access to the relevant Apex classes
4) and Access to the four custom settings prefixed with Dynacat and TileWall.

The package includes a permission set called Dynacat Community Viewer Permissions that contains all these permissions.

You also need to configure Org-Wide Defaults and/or Sharing Rules (for Guest Users) to make sure that the users can see all the records, attributes, and record attrbutes.




# Option: Build Your Own UI for Dynacat

Tile Wall is designed to provide a configurable experience to meet many display requirements.  And Dynacat is designed to provide a flexible set of filters that can be used in many different use cases.  The two can be used quite independently of each other though, if you love to code it’s (relatively) straight-forward to build your own UI to display records from Dynacat.  The package includes a simple client-based and server-based catalog example to get you started, I’ve also built out more complex layouts for demos.  If you’ve got an idea, please let me know and I’m happy to talk you through the code.
