/**
 * QuestionDetailController.m
 *
 * See header file.
 **/

#import "InquireAppDelegate.h"
#import "Constants.h"
#import "QuestionDetailController.h"
#import "AnswerQuestionController.h"
#import "AnswerModel.h";

#define NO_ANSWER_TEXT @"There are no answers for this question. Use the Answer button to supply one!";

enum {
	kQuestionSection = 0,
	kAnswerSection
};

@implementation QuestionDetailController
@synthesize question;
@synthesize answers;
@synthesize tableView;

/**
 * Initialize the view with a QuestionModel object. We use this
 * to pull various details about the question as well as load
 * a list of answer objects from the server.
**/ 
- (id)initWithQuestionModel:(QuestionModel *)aQuestion {
	self = [super init];
	if(self != nil) {
		self.question = aQuestion;
		
		self.title = @"Question Details";
		// Create a right bar button for answering this question. When touched
		// the handleAnswerButton method will be called.
		//self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(handleAnswerButton:)] autorelease];
		
		// Create a button for asking answering the question and place it in the
		// right side of the navigation bar
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Answer" 
																				   style:UIBarButtonItemStyleBordered 
																				  target:self 
																				  action:@selector(handleAnswerButton:)] autorelease];
	}
	return self;
}

/**
 * When the view is about to be shown we ask the API for a list
 * of answers for this question. When the request is finished we
 * reload the table view to display those answers.
**/
- (void)viewWillAppear:(BOOL)animated {
	InquireAPI *api = [[InquireAPI alloc] initWithBaseURL:BASE_API_URL andDelegate:self];
	[api getAnswersForQuestion:self.question];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[self.answers release];
	[self.tableView release];
}


- (void)dealloc {
	[answers release];
	[tableView release];
    [super dealloc];
}

#pragma mark -
#pragma mark Utility Messages

-(void)buildAnswers:(NSArray *)rawAnswers {
	if(self.answers == nil) {
		self.answers = [[NSMutableArray alloc] init];
	}
	[self.answers removeAllObjects];
	
	int userId = [[APP_DELEGATE currentUser] userId];
	NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:[rawAnswers count]];
	for(NSDictionary *rawAnswer in rawAnswers) {
		AnswerModel *answer = [[[AnswerModel alloc] initWithDictionary:rawAnswer ownerId:userId] autorelease];
		[self.answers addObject:answer];
	}
	[list release];
	
	NSLog(@"Built %d Answer objects.", [self.answers count]);
	
	// Refresh the table view
	[self.tableView reloadData];
	
}

#pragma mark -
#pragma mark UITableViewDelegate Messages

/**
 * Configures the editing capabilities of the table view. The Question section
 * is never editable and the answers section is only editable if there are
 * answers available and the current user is the owner of the question.
**/
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == kQuestionSection || !self.question.isOwner) {
		return UITableViewCellEditingStyleNone;
	} else {
		if([self.answers count] == 0) {
			return UITableViewCellEditingStyleNone;
		} 
	}

	return UITableViewCellEditingStyleDelete;
}

/**
 * When the user commits the editing (which in our case is an accept camouflaged as
 * a delete) we fire off an API request to let the user know a question has been
 * accepted
**/
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if(editingStyle == UITableViewCellEditingStyleDelete) {
		// Get a reference to the answer being accepted
		AnswerModel *a = [answers objectAtIndex:indexPath.row];
		
		// Accept the answer via the API
		InquireAPI *api = [[InquireAPI alloc] initWithBaseURL:BASE_API_URL andDelegate:self];
		[api acceptAnswer:a];
	}
}

/**
 * Modify the default "Delete" edit button for swiping to be labeled as "Accept"
**/
- (NSString *)tableView:(UITableView *)tv titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	return @"Accept";
}

/**
 * Dynamically calculate the height of a table cell based on the content of the cell.
**/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellText;
	if(indexPath.section == kQuestionSection) {
		cellText = self.question.questionText;
	} else {
		if([self.answers count] == 0) {
			cellText = NO_ANSWER_TEXT;
		} else {
			cellText = ((AnswerModel *)[self.answers objectAtIndex:indexPath.row]).answerText;
		}
	}
	
	// Make use of the sizeWithFont message for helping us determine the proper height
	// of a table cell.
	UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:14.0];
	CGSize constraintSize = CGSizeMake(280.0f, CGFLOAT_MAX);
	CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	
	// Return the calculated size plus a few pixels for padding
	return labelSize.height + 25.0;
}

#pragma mark -
#pragma mark UITableViewDataSource Messages

/**
 * Builds and returns a UITableViewCell with the appropriate content. If we're in 
 * the first section we return a cell with the question text, otherwise we return
 * a table cell with the appropriate answer text.
**/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
	// Question cell
	if(indexPath.section == kQuestionSection) {
		cell = [self.tableView dequeueReusableCellWithIdentifier:@"questionCell"];
		if(cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"questionCell"];
		}
		cell.textLabel.text = self.question.questionText;
	} 
	// Answer cell
	else {
		cell = [self.tableView dequeueReusableCellWithIdentifier:@"answerCell"];
		if(cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"answerCell"];
		}
		
		if([self.answers count] == 0) {
			cell.textLabel.text = NO_ANSWER_TEXT;
		} else {
			cell.textLabel.text = [(AnswerModel *)[self.answers objectAtIndex:indexPath.row] answerText];
		}
	}
	
	// Set wordwrap to true and the font name and size
	cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
	cell.textLabel.numberOfLines = 0;
	cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
	
	return cell;
}

/**
 * Return the appropriate header titles for the given section
**/
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if(section == kQuestionSection) {
		return @"Question";
	} else {
		return @"Answers";
	}
}

/**
 * Return the footer for the question section. Answer section has no footer.
**/
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if(section == kQuestionSection) {
		if(self.question.isOwner) {
			return @"You own this question. Swipe an answer to accept it.";
		}
	}
	return nil;
}

/**
 * There are two sections in our table
**/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

/**
 * For the question section we always return one and for answers we return the
 * length of our answers array.
**/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == kQuestionSection) {
		return 1;
	} else {
		if([self.answers count] == 0) {
			return 1;
		}
		return [self.answers count];
	}
}

#pragma mark -
#pragma mark InquireAPIDelegate Messages

/**
 * InquireAPI success delegate message
 **/
- (void)apiRequestFinished:(InquireAPI *)api response:(NSDictionary *)jsonResponse {
	NSLog(@"%@", jsonResponse);
	
	// Check the "success" parameter in the JSON response object
	if([(NSNumber *)[jsonResponse objectForKey:@"success"] boolValue] == YES) {
		// Response to getAnswersForQuestion:
		if(api.apiMethod == API_METHOD_ANSWERS) {
			// Build the answer objects to drive our table view
			[self buildAnswers:[jsonResponse objectForKey:@"answers"]];
		}
		// Response to acceptAnswer, which means the question is closed and we
		// should pop from the navigation stack
		else if(api.apiMethod == API_METHOD_ACCEPT) {
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
	else {
		// The JSON response from the server indicated an unsuccessful request.
		// Show an alert with the details.
		[APP_DELEGATE showAlertWithTitle:@"" message:(NSString*)[jsonResponse objectForKey:@"msg"]];
	}
	
	// Release the API
	[api release];
}

/**
 * InquireAPI failure delegate message
 **/
- (void)apiRequestFailed:(InquireAPI *)api error:(NSError *)error {
	[APP_DELEGATE showAlertWithTitle:@"" message:[error localizedDescription]];
}

#pragma mark -
#pragma mark UI Actions

/**
 * When the answer button is touched we build a AnswerQuestionController and push it
 * on the navigation controller so the user can compose a answer. Do not allow the
 * user who asked the question to answer their own question though!
**/
- (void)handleAnswerButton:(id)sender {
	// Check to see if the current user is the owner
	if(self.question.isOwner) {
		[APP_DELEGATE showAlertWithTitle:@"" message:@"Sorry, you can't answer your own question!"];
		return;
	}
	
	AnswerQuestionController *aqc = [[[AnswerQuestionController alloc] initWithQuestion:self.question] autorelease];
	[self.navigationController pushViewController:aqc animated:YES];
}

@end
