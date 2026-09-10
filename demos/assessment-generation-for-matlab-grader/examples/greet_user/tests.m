%% Assessment: Return the requested greeting.
name = "Ben F";
greeting = greetUser(name);
greetingReference = reference.greetUser(name);
assessVariableEqual('greeting', greetingReference);

%% Assessment: The function displays the greeting.
name = "Ben F";
studentDisplay = string(evalc("greetUser(name);"));
greetingReference = reference.greetUser(name);
displaysGreeting = contains(studentDisplay, greetingReference);
assessVariableEqual('displaysGreeting', true);
