function [dio_input_channel] = initialisedio(q)
% LEGACY MODE %INITIALISEDIO Intitialises NI DAQ. 
% %If in testing mode, skip DAQ intialisation and return an empty string
% if ~q.testingMode
%     dio = digitalio('nidaq', q.deviceName);
%     dio_input_channel = addline(dio, q.inputLine, q.inputPort, 'in');
% else
%     dio_input_channel = '';
% end
% end

%INITIALISEDIO Intitialises NI DAQ. 
%If in testing mode, skip DAQ intialisation and return an empty string
 if ~q.testingMode
     q.input = daq.createSession('ni'); 
     addDigitalChannel(q.input, q.deviceName, ...
         ['port' num2str(q.inputPort) '/line' num2str(q.inputLine)], 'InputOnly');
     dio_input_channel = q.input;
 else
     dio_input_channel = '';
 end
 end
