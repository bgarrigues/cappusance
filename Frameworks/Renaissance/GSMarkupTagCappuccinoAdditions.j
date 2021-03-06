
@import "GSMarkupTagView.j"

@implementation GSMarkupTagProgressIndicator : GSMarkupTagView
+ (CPString) tagName
{
  return @"progressIndicator";
}

+ (Class) platformObjectClass
{
  return [CPProgressIndicator class];
}

- (id) initPlatformObject: (id)platformObject
{	platformObject = [super initPlatformObject: platformObject];

	var min;
	var max;
	var current;
	if([self boolValueForAttribute: @"indeterminate"] ==1)
	{	[platformObject setIndeterminate:YES];
		[platformObject setStyle: CPProgressIndicatorSpinningStyle];
		[platformObject setControlSize: CPMiniControlSize];
		[_attributes setObject: @"16" forKey: @"height"]
		[_attributes setObject: @"16" forKey: @"width"]
	}
	if([self boolValueForAttribute: @"displayWhenStopped"] ==1)
		[platformObject  setDisplayedWhenStopped:YES];

	min = [_attributes objectForKey: @"min"];
	if (min != nil)
    {	[platformObject setMinValue: [min doubleValue]];
    }

	max = [_attributes objectForKey: @"max"];
	if (max != nil)
    {	[platformObject setMaxValue: [max doubleValue]];
    }

  /* minimum size is 83x17*/
	var height;
	height = [_attributes objectForKey: @"height"];
	if (height == nil)
	{
		[_attributes setObject: @"16" forKey: @"height"];
	}
	var width;
	width = [_attributes objectForKey: @"width"];
	if (width == nil)
    {	[_attributes setObject: @"83" forKey: @"width"];
    }

	return platformObject;
}
@end

@implementation GSMarkupOperator: GSMarkupTagObject

+ (CPString) tagName
{
  return @"operator";
}
-(CPArray) content
{	return _content;
}
/* Will never be called.  */
- (id) allocPlatformObject
{	return nil;
}
-(CPNumber) operator
{	var type= [_attributes objectForKey:"type"];
	if( type == "equal") return [CPNumber numberWithInt: CPEqualToPredicateOperatorType];
	else if( type == "begins") return [CPNumber numberWithInt: CPBeginsWithPredicateOperatorType];
	else if( type == "ends") return [CPNumber numberWithInt: CPEndsWithPredicateOperatorType];
	return nil
}
@end


@implementation GSMarkupLexpression: GSMarkupTagObject

+ (CPString) tagName
{
  return @"lexpression";
}
-(CPArray) content
{	return _content;
}
/* Will never be called.  */
- (id) allocPlatformObject
{	return nil;
}
-(CPString) keyPath
{	return [_attributes objectForKey:"keyPath"];
}
@end

@implementation GSMarkupRexpression: GSMarkupTagObject

+ (CPString) tagName
{
  return @"rexpression";
}
-(CPArray) content
{	return _content;
}
/* Will never be called.  */
- (id) allocPlatformObject
{	return nil;
}
-(CPString) keyPath
{	return [_attributes objectForKey:"keyPath"];
}
@end


@implementation GSMarkupRowTemplate: GSMarkupTagObject

+ (CPString) tagName
{
  return @"rowTemplate";
}
/* Will never be called.  */
- (id) allocPlatformObject
{	return nil;
}
@end

@implementation CPPredicateEditor(SizeToFitFix)
-(void) sizeToFit
{
}
@end

@implementation GSMarkupTagPredicateEditor : GSMarkupTagView
+ (CPString) tagName
{	return @"predicateEditor";
}

+ (Class) platformObjectClass
{	return [CPPredicateEditor class];
}

- (id) initPlatformObject: (id)platformObject
{	platformObject = [super initPlatformObject: platformObject];

// now extract columns and PK...
	var rowTemplates=[CPMutableArray new];
    var i, count = _content.length;
	for (i = 0 ; i < count; i++)
	{	var v = _content[i];
		if([v isKindOfClass: [GSMarkupRowTemplate class] ])
		{	var expressions=[v content];
			var j,l1=expressions.length;
			var lexpressions=[CPMutableArray new];
			var ops=[CPMutableArray new];
			for(j=0;j<l1;j++)
			{	var expr=expressions[j];
				if([expr isKindOfClass: [GSMarkupLexpression class] ])
					[lexpressions addObject: [CPExpression expressionForKeyPath: [expr keyPath] ]];
				else if([expr isKindOfClass: [GSMarkupOperator class] ])
					 if([expr operator]) [ops addObject: [expr operator]];
			}
			var rowTemplate=[[CPPredicateEditorRowTemplate alloc]
				 initWithLeftExpressions: lexpressions
			rightExpressionAttributeType: CPStringAttributeType		//<!> fixme
								modifier: 0	//<!> fixme
							   operators: ops
								 options: 0];	//<!> fixme
			[rowTemplates addObject: rowTemplate];
		}
	}

	[platformObject setNestingMode: CPRuleEditorNestingModeCompound];
	[rowTemplates addObject: [ [CPPredicateEditorRowTemplate alloc] initWithCompoundTypes:
			[CPArray arrayWithObjects: [CPNumber numberWithInt: CPAndPredicateType], [CPNumber numberWithInt: CPOrPredicateType], [CPNumber numberWithInt: CPNotPredicateType]  ] ] ];
	[platformObject setRowTemplates: rowTemplates];
	[platformObject setFormattingStringsFilename: nil];	// fixes capp issue
	return platformObject;
}
@end

@implementation GSMarkupTagPredicate : GSMarkupTagObject
+ (CPString) tagName
{	return @"predicate";
}

+ (Class) platformObjectClass
{	return nil;
}

- (id) initPlatformObject: (id)platformObject
{	platformObject=[CPPredicate predicateWithFormat: [_attributes objectForKey:"format"] argumentArray: nil ];
	return platformObject;
}
@end

@implementation GSMarkupTagTabViewItem : GSMarkupTagObject
+ (CPString) tagName
{
  return @"tabViewItem";
}

+ (Class) platformObjectClass
{
  return nil;
}

-(CPString) title
{	return [_attributes objectForKey:"title"];
}
- (id) initPlatformObject: (id)platformObject
{	platformObject=[[CPTabViewItem alloc] initWithIdentifier: [self title] ];
	return platformObject;
}
@end

@implementation GSMarkupTagTabView : GSMarkupTagView
+ (CPString) tagName
{
  return @"tabView";
}

+ (Class) platformObjectClass
{
  return [CPTabView class];
}

-(int) type
{	if([_attributes objectForKey: "type"]=="topBezel") return CPTopTabsBezelBorder;
	return CPNoTabsBezelBorder;
}
- (id) initPlatformObject: (id)platformObject
{	platformObject = [super initPlatformObject: platformObject];
	[platformObject setTabViewType: [self type]];

    var  i, count = _content.length;
	for (i = 0 ; i < count; i++)
	{	var item = [_content[i] platformObject];
        [item setView: [[_content[i] content][0] platformObject] ];
        [item setLabel: [_content[i] title] ];
		[platformObject addTabViewItem: item];
	}
	return platformObject;
}
@end

@implementation  CPTabView(AutoLayoutDefaults)
- (GSAutoLayoutAlignment) autolayoutDefaultVerticalAlignment
{	return GSAutoLayoutExpand;
}
- (GSAutoLayoutAlignment) autolayoutDefaultHorizontalAlignment
{	return GSAutoLayoutExpand;
}

@end


@implementation GSMarkupTagCheckBox : GSMarkupTagControl
+ (CPString) tagName
{
  return @"checkBox";
}

+ (Class) platformObjectClass
{
  return [CPCheckBox class];
}

- (id) initPlatformObject: (id)platformObject
{	platformObject = [super initPlatformObject: platformObject];
	[platformObject setTitle: [_attributes objectForKey:"title"] ];
	return platformObject;
}
@end

