API Keywords and Test Automation Framework
This project contains the Robot Framework implementation of an automated testing suite for various APIs, including those used by My App, Cart, and Azure DevOps. The framework includes keywords for interacting with these APIs, as well as additional libraries and dependencies.

Table of Contents
Introduction
Prerequisites
Setup
API Keywords
Test Automation Framework
Introduction
This project aims to provide a comprehensive and maintainable framework for testing various APIs using the Robot Framework. The goal is to ensure that all API endpoints are thoroughly tested, reducing the likelihood of defects and improving overall system reliability.

Prerequisites
Before running this project, make sure you have:

Python 3.x installed
Robot Framework installed (pip install robotframework)
Additional libraries (listed below) installed
Setup
To set up this project:

Clone this repository using git clone <repository-url>
Create a new virtual environment using python -m venv env
Activate the virtual environment using source env/bin/activate (on Linux/macOS) or env\Scripts\activate (on Windows)
Install required libraries using pip install -r requirements.txt
API Keywords
This project contains several API-related keywords, including:

Get Order Details: Retrieves order details from the My App API
Approve/Reject Order: Approves or rejects an order based on a decision parameter
Cart APIs: Interacts with cart-related endpoints (get current cart, get all carts, delete item from cart, delete cart)
Azure DevOps API: Interacts with Azure DevOps API endpoints (update test status)
Test Automation Framework
This project includes a Robot Framework-based test automation framework for testing the aforementioned APIs. The framework is designed to be flexible and maintainable, allowing you to easily add or modify tests as needed.

Features
Test Suite Management: Organize tests into suites using the Suite class
API Interactions: Use keywords from the APICalls library to interact with API endpoints
Assertion Library: Utilize the Asserts library for assertions and error handling
Custom Libraries: Leverage custom libraries (e.g., PyFunctions.py) to extend framework functionality
Contributing
Contributions are welcome! If you'd like to contribute, please:

Fork this repository
Create a new branch using git checkout -b <branch-name>
Implement your changes and write tests as needed
Run the test suite using robot
Commit your changes and push them to your fork
License
This project is licensed under the MIT License. See LICENSE.txt for details.

I hope this README.md file meets your expectations! Let me know if you need further assistance
