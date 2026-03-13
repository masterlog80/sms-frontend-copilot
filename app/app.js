// app/app.js

// Function to send SMS
function sendSMS(number, message) {
    const characterLimit = 160;
    const bookmarks = [];
    let balance = 100; // Assume initial balance

    // Check character limit
    if (message.length > characterLimit) {
        console.log(`Message exceeds character limit of ${characterLimit}.`);
        return;
    }

    // Check balance
    if (balance <= 0) {
        console.log('Insufficient balance to send SMS.');
        return;
    }

    // Simulate sending SMS
    console.log(`Sending SMS to ${number}: ${message}`);
    balance -= 1; // Deduct balance for sending the SMS
    console.log(`Balance now: ${balance}`);
}

// Function to add bookmark
function addBookmark(message) {
    bookmarks.push(message);
    console.log('Bookmark added: ' + message);
}

// Display balance
function displayBalance() {
    console.log('Current balance: 100'); // Display the current balance
}

// Example usage
sendSMS('+1234567890', 'Hello, this is a test message!');
addBookmark('Hello, this is a test message!');
displayBalance();
