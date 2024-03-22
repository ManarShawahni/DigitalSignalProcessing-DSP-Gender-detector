function varargout = untitled2(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name', mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @untitled2_OpeningFcn, ...
                       'gui_OutputFcn',  @untitled2_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
end

function untitled2_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    [handles.ZCR_fem, handles.ZCR_male] = calculateAverageZCRAndEnergyFromTrainingData();
    guidata(hObject, handles);
end

function varargout = untitled2_OutputFcn(hObject, eventdata, handles)
    varargout{1} = handles.output;
end

function [ZCR_fem, ZCR_male] = calculateAverageZCRAndEnergyFromTrainingData()
    trainfiles_female = dir('C:\Users\USER\Desktop\matlab assign\Train\Female\*.wav');
    trainfiles_male = dir('C:\Users\USER\Desktop\matlab assign\Train\Male\*.wav');

% Calculate average ZCR and energy for 'female' training files
data_fem = [];
for i = 1:length(trainfiles_female)
    filepath = strcat(trainfiles_female(i).folder,'\',trainfiles_female(i).name);
    [y,fs] = audioread(filepath);

    ZCR_fem1 = mean(abs(diff(sign(y(1:floor(end/3))))))./2;
    ZCR_fem2 = mean(abs(diff(sign(y(1:floor(end/3):floor(end*2/3))))))./2;
    ZCR_fem3 = mean(abs(diff(sign(y(1:floor(end/3):end)))))./2;

    energy = sum(sum(y.^2));
    
    % Calculate correlation
    [correlation_fem, lags] = xcorr(y(1:end-1), y(2:end), 'coeff');
    correlation_fem = correlation_fem(floor(length(correlation_fem)/2));

    % Calculate power spectral density
    [pxx_fem, f] = periodogram(y, rectwin(length(y)), length(y), fs);
    pxx_fem = sum(pxx_fem(f>0));

   % Update your feature vector to include these new features
   features_fem = [ZCR_fem1 ZCR_fem2 ZCR_fem3 energy correlation_fem pxx_fem];
   data_fem = [data_fem ;features_fem];
end


    % Calculate average ZCR and energy for 'male' training files
    data_male = [];
    for i = 1:length(trainfiles_male)
        filepath = strcat(trainfiles_male(i).folder,'\',trainfiles_male(i).name);
        [y,fs] = audioread(filepath);

        ZCR_male1 = mean(abs(diff(sign(y(1:floor(end/3))))))./2;
        ZCR_male2 = mean(abs(diff(sign(y(1:floor(end/3):floor(end*2/3))))))./2;
        ZCR_male3 = mean(abs(diff(sign(y(1:floor(end/3):end)))))./2;

        energy = sum(sum(y.^2));
        
        
         % Calculate correlation
        [correlation_male, lags] = xcorr(y(1:end-1), y(2:end), 'coeff');
        correlation_male = correlation_male(floor(length(correlation_male)/2));
    
     % Calculate power spectral density
       [pxx_male, f] = periodogram(y, rectwin(length(y)), length(y), fs);
       pxx_male = sum(pxx_male(f>0)); 


    % Update your feature vector to include these new features
   features_male = [ZCR_male1 ZCR_male2 ZCR_male3 energy correlation_male pxx_male];
   data_male = [data_male ;features_male];
        
    end
    
     ZCR_fem = mean(data_fem);
    ZCR_male = mean(data_male);
end

function gender = classifyGender(ZCR, energy, correlation, pxx, ZCR_fem, ZCR_male)
    % Concatenate ZCR, energy, correlation, and pxx into a single vector
    y_ZCR = [ZCR energy correlation pxx];

    % Calculate distances
    dist_fem = pdist([y_ZCR; ZCR_fem]);
    dist_male = pdist([y_ZCR; ZCR_male]);

    % Print distances for debugging
    fprintf('Distances - Female: %f, Male: %f\n', dist_fem, dist_male);

    % Classify gender based on Euclidean distance
    if dist_fem < dist_male
        gender = 'Female';
    else
        gender = 'Male';
    end
end

function start_Callback(hObject, eventdata, handles)
    handles.recObj = audiorecorder(44100, 16, 1);
    fprintf('Recording started...\n');
    record(handles.recObj);
    guidata(hObject, handles);
end

function stop_Callback(hObject, eventdata, handles)
    fprintf('Recording stopped.\n');
    if isfield(handles, 'recObj') && ~isempty(handles.recObj)
        stop(handles.recObj);
        
        % Get and plot time domain signal
        y = getaudiodata(handles.recObj);
        fs = handles.recObj.SampleRate;  
       
        plot(handles.axes1, y);
        title(handles.axes1, 'Time Domain Signal');
        xlabel(handles.axes1, 'Time');
        ylabel(handles.axes1, 'Amplitude');

        % Plot frequency domain signal
        f = abs(fft(y));
        
        index_f = 1:length(f);
        index_f = index_f ./ length(f);
        index_f = index_f * handles.recObj.SampleRate;
        % Normalize f
        f = f - min(f(:));
        f = f ./ max(f(:));
        plot(handles.axes2, index_f, f);
        title(handles.axes2, 'Frequency Domain Signal');
        xlabel(handles.axes2, 'Frequency (Hz)');
        ylabel(handles.axes2, 'Amplitude');

        [ZCR, energy] = calculateZCRAndEnergy(y);
        
        % Calculate correlation
        [correlation, lags] = xcorr(y(1:end-1), y(2:end), 'coeff');
        correlation = correlation(floor(length(correlation)/2));

        % Calculate power spectral density
        [pxx, f] = periodogram(y, rectwin(length(y)), length(y), fs);
        pxx = sum(pxx(f>0));

        % Assuming ZCR, energy, correlation, and pxx are defined somewhere in your code
        gender = classifyGender(ZCR, energy, correlation, pxx, handles.ZCR_fem, handles.ZCR_male);


        set(handles.zcrc, 'String', num2str(ZCR));
        set(handles.edit3, 'String', gender);

        selectedGender = getSelectedGender(handles);
        accuracy = calculateAccuracy(gender, selectedGender);
        set(handles.accc, 'String', num2str(accuracy));

        handles = rmfield(handles, 'recObj');
    else
        fprintf('No recording to stop.\n');
    end
end

% --- Executes on button press in fem.
function fem_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value') == 1
        set(handles.male, 'Value', 0);
        updateAccuracy(handles);
    end
end

% --- Executes on button press in male.
function male_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value') == 1
        set(handles.fem, 'Value', 0);
        updateAccuracy(handles);
    end
end

function updateAccuracy(handles)
    if isfield(handles, 'recObj') && ~isempty(handles.recObj)
        % Continue only if there is a recording
        selectedGender = getSelectedGender(handles);
        if ~isempty(selectedGender)
            % If a gender is selected, update the accuracy display
            set(handles.accc, 'String', 'Waiting for recording to stop...');
            drawnow; % Ensure that the display updates immediately

            % Get recorded data and classify gender
            y = getaudiodata(handles.recObj);
            fs = handles.recObj.SampleRate; 
            
            % Get recorded data and classify gender
            y = getaudiodata(handles.recObj);
            [ZCR, energy] = calculateZCRAndEnergy(y);

            % Calculate correlation
            [correlation, lags] = xcorr(y(1:end-1), y(2:end), 'coeff');
            correlation = correlation(floor(length(correlation)/2));

            % Calculate power spectral density
            [pxx, f] = periodogram(y, rectwin(length(y)), length(y), fs);
            pxx = sum(pxx(f>0));

            gender = classifyGender(ZCR, energy, correlation, pxx, handles.ZCR_fem, handles.ZCR_male);
            % Update the accuracy display
            accuracy = calculateAccuracy(gender, selectedGender);
            set(handles.accc, 'String', num2str(accuracy));
        end
    end
end


function [ZCR, energy] = calculateZCRAndEnergy(y)
    % Calculate TEXT4
    ZCR1 = mean(abs(diff(sign(y(1:floor(end/3))))))./2;
    ZCR2 = mean(abs(diff(sign(y(1:floor(end/3):floor(end*2/3))))))./2;
    ZCR3 = mean(abs(diff(sign(y(1:floor(end/3):end)))))./2;
    ZCR = [ZCR1 ZCR2 ZCR3];

    % Calculate energy
    energy = sum(y.^2);
end


function selectedGender = getSelectedGender(handles)
    if get(handles.fem, 'Value') == 1
        selectedGender = 'Female';
    elseif get(handles.male, 'Value') == 1
        selectedGender = 'Male';
    else
        selectedGender = '';
    end
end

function accuracy = calculateAccuracy(gender, selectedGender)
    if strcmp(gender, selectedGender)
        accuracy = 100;
    else
        accuracy = 0;
    end
end

function zcrc_Callback(hObject, eventdata, handles)
% hObject    handle to zcrc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zcrc as text
%        str2double(get(hObject,'String')) returns contents of zcrc as a double
end

% --- Executes during object creation, after setting all properties.
function zcrc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zcrc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function accc_Callback(hObject, eventdata, handles)
% hObject    handle to accc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of accc as text
%        str2double(get(hObject,'String')) returns contents of accc as a double
end

% --- Executes during object creation, after setting all properties.
function accc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to accc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
end

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes during object creation, after setting all properties.
function text4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
end
