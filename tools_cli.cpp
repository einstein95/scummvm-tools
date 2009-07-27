/* tools_cli - CLI interface for the tools
 * Copyright (C) 2009 The ScummVM project
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * $URL
 * $Id
 *
 */

#include <iostream>

#include "tools_cli.h"

ToolsCLI::ToolsCLI() {
}

ToolsCLI::~ToolsCLI() {
}

int ToolsCLI::run(int argc, char *argv[]) {
	// No matter what we ouput, we should begin with a newline
	std::cout << "\n"; 

	if (argc == 1) {
		// Run without any arguments
		printHelp();
		return 0;
	}

	std::deque<char *> arguments(argv, argv + argc);
	arguments.pop_front(); // Pop our own name

	ToolType type = TOOLTYPE_ALL;

	// Check first argument
	std::string option = arguments.front();
	if (option == "--tool" || option == "-t") {
		arguments.pop_front();
		for (ToolList::iterator iter = _tools.begin(); iter != _tools.end(); ++iter) {
			Tool *tool = *iter;
			if (arguments.front() == tool->getName()) {
				// Run the tool, first argument will be name, very nice!
				return tool->run(arguments.size(), &arguments.front());
			}
		}
		std::cout << "\tUnknown tool, make sure you input one of the following:\n";
		printTools();
	} else if (option == "--help" || option == "-h") {
		printHelp();
	} else if (option == "--list" || option == "-l") {
		printTools();
	} else {
		// Allow user to the narrow choices
		if(option == "compress") {
			type = TOOLTYPE_COMPRESSION;
			arguments.pop_front();
		} else if(option == "extract") {
			type = TOOLTYPE_EXTRACTION;
			arguments.pop_front();
		}

		// Find out what tools take this file as input
		ToolList choices = inspectInput(type, arguments);
		Tool *tool = NULL;

		if (choices.size() > 1) {
			std::cout << "\tMultiple tools accept this input:\n\n";

			// Present a list of possible tools
			int i = 1;
			for (ToolList::iterator choice = choices.begin(); choice != choices.end(); ++choice, ++i) {
				std::cout << "\t" << i << ") " << (*choice)->getName() << "\n";
			}

			std::cout << "Which tool to use: ";
			i = 0;
			while(true) {

				// Read input
				std::cin >> i;

				// Valid ?
				if(std::cin && i >= 1 && (size_t)i < choices.size())
					break;

				std::cout << "Invalid input, try again: ";

				// Clear any error flags
				std::cin.clear();

				// Skip invalid input characters
				std::cin.ignore(1000, '\n');
			}

			// Account for the fact arrays start at 0
			tool = choices[i - 1];
		} else {
			tool = choices.front();
		}

		std::cout << "\tRunning using " << tool->getName() << "\n";
		
		// Run the tool, with the remaining arguments
		// We also add the name of the tool so it can displayed (requires an evil cast but it's safe)
		std::string name = tool->getName();
		arguments.push_front(const_cast<char *>(name.c_str()));
		return tool->run(arguments.size(), &arguments.front());
	}

	return 0;
}

void ToolsCLI::printHelp() {
	std::cout << 
		"\tScumm VM Tools master interface\n" <<
		"\n" <<
		"\tCommon use:\n" <<
		"\ttools [--tool <tool name>] [compression options] [-o output directory] <input args>\n" <<
		"\ttools [extract|compress] <input args>\n" <<
		"\n" <<
		"\tOther Options:\n" <<
		"\t--help\tDisplay this text\n" <<
		"\t--list\tList all tools that are available\n" <<
		"";
}

void ToolsCLI::printTools() {
	std::cout << "\nAll available tools:\n";
	for (ToolList::iterator tool = _tools.begin(); tool != _tools.end(); ++tool)
		// There *really* should be a short version of the help text available
		std::cout << "\t" << (*tool)->getName() << ":\t" << (*tool)->getShortHelp() << "\n";
}


