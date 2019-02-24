function VREPS_regler(A)
    %close all; clear all; clc;
            %inits
        sim_buffer=1500;
        Kraft_rechts=zeros(1,sim_buffer);
        Kraft_links=zeros(1,sim_buffer);
        position_x=zeros(1,sim_buffer);
        position_y=zeros(1,sim_buffer);
        winkel=zeros(1,sim_buffer);
        loswinkel=zeros(1,sim_buffer);
        fehlerwinkel=zeros(1,sim_buffer);
        zeit=1:sim_buffer;
        pos_x=0;
        pos_y=0;
        pos_r=[];
        pos_l=[];
        ang=[];
        phi=0;
        phi_alt=0;
        timestep=0.01;
        sz=size(A);
        i=1;
        R_shp=2;
        t=0;
        R_pkt=0.5;
        Fr=0;
        Fl=0;

    
    disp('Programm gestartet');
    vrep=remApi('remoteApi'); % Vorgefertigtes .m file benutzen
    vrep.simxFinish(-1); % alle offenen Verbindungen schlie�en.
    clientID=vrep.simxStart('127.0.0.1',19997,true,true,5000,5); %Serverstart

    if (clientID>-1)
        disp('Server connected');
        vrep.simxStartSimulation(clientID,vrep.simx_opmode_oneshot); %einmaliges Starten der Simulation
                
        %Beziehen der Handle
        [~,rechts_dyn]=vrep.simxGetObjectHandle(clientID, 'rechts_dyn',vrep.simx_opmode_blocking);
        [~,links_dyn]=vrep.simxGetObjectHandle(clientID, 'links_dyn',vrep.simx_opmode_blocking);
   
        [returnCode,pos_r]=vrep.simxGetObjectPosition(clientID,rechts_dyn,-1,vrep.simx_opmode_streaming);
        [returnCode,pos_l]=vrep.simxGetObjectPosition(clientID,links_dyn,-1,vrep.simx_opmode_streaming);
        [returnCode,angle_string]=vrep.simxGetStringSignal(clientID,'angle_r',vrep.simx_opmode_streaming);
%         %Mittelpunkt berechnen:
%         pos_x=(pos_r(1) + pos_l(1))/2;
%         pos_y=(pos_r(2) + pos_l(2))/2;
        

        


        %Einmaliges initialisierendes Auslesen der Matrix:
        x_k1=A(i,1);
        y_k1=A(i,2);
        x_k2=A(i+1,1);
        y_k2=A(i+1,2); 

        %Radius vom Schiff muss immer kleiner/gleich Radius vom Zielpunkt
        %sein. Sonst falsches Ergebnis!        
        %A ist definiert als [p0 ; p1; p2; p3] also:
        % 0 0
        % 10 10
        % usw...
        %
        %A ist also eine Nx2 Matrix.
        %Dann kann mit size() die menge an punkten in A �bernommen werden.
        %Die punkte werden nacheinander abgefahren und mittels if-bedingung
        %gewechselt, bis der letzte punkt erreicht ist. Die Punkte d�rfen
        %nicht �ber 90� hinaus gehen. 
        
 
%%
        while (clientID ~= -1)
        t=t+1;

            
        [returnCode,pos_r]=vrep.simxGetObjectPosition(clientID,rechts_dyn,-1,vrep.simx_opmode_streaming);
        [returnCode,pos_l]=vrep.simxGetObjectPosition(clientID,links_dyn,-1,vrep.simx_opmode_streaming);
        [returnCode,angle_string]=vrep.simxGetStringSignal(clientID,'angle_r',vrep.simx_opmode_streaming);
            if (returnCode==vrep.simx_return_ok)
            ang=vrep.simxUnpackFloats(angle_string);
            end
        %Mittelpunkt berechnen:
        pos_x=(pos_r(1) + pos_l(1))/2;
        pos_y=(pos_r(2) + pos_l(2))/2;
        
        
        if (sqrt((x_k2-pos_x)^2+(y_k2-pos_y)^2)<=R_pkt) && i+1==sz(1) %wenn k2 letzer punkt war, ziel erreicht!
            disp('Zielpunkt erreicht');
            break  %beenden des Programms, falls Zielpunkt erreicht
        end              
        
        
        %Abfragen, ob Wegpunkts-Radius von K2 erreicht wurde:
        if sqrt((x_k2-pos_x)^2+(y_k2-pos_y)^2)<=R_pkt && (i+1<sz(1))
            disp('Wegpunkt erreicht');
            i=i+1;
            phi_alt=0;
        end
  

        %Auslesen der Matrix, falls i sich ge�ndert hat:
        x_k1=A(i,1);
        y_k1=A(i,2);
        x_k2=A(i+1,1);
        y_k2=A(i+1,2);
        
        %L�sung des Gleichungssystems nach x_los,y_los:    
        delta_y=y_k2-y_k1;
        delta_x=x_k2-x_k1;
        
        if abs(delta_x)>0
            d=delta_y/delta_x;
            e=x_k1;
            f=y_k1;
            g=f-d*e;
            a=1+d^2;
            b=2*(d*g-d*pos_y-pos_x);
            c=(pos_x)^2+(pos_y)^2+g^2-2*g*pos_y-(R_shp)^2;
            if delta_x>0
                x_los=(-b+sqrt(b^2-4*a*c))/(2*a);
            end
            if delta_x<0
                x_los=(-b-sqrt(b^2-4*a*c))/(2*a);
            end
            y_los=d*(x_los-x_k1)+y_k1;
        end
        if abs(delta_x)==0
            x_los=x_k1;
            if delta_y>0
                y_los=pos_y+sqrt(R_shp^2-(x_los-pos_x)^2);
            end
            if delta_y<0
                y_los=pos_y-sqrt(R_shp^2-(x_los-pos_x)^2);
            end
        end
        
        %Winkelberechnung mit LOS-Punkt:        
        phi_los=atan2(y_los-pos_y,x_los-pos_x);

        %Fehlerwinkel berechnen:
        %Fallunterscheidung, um das Togglen von atan2 auszugleichen:
        if abs(ang)>2 || abs(phi_los)>2 %wenn beide winkel im toggle-bereich sind  
            if phi_los>0
                if ang>0
                         if ang>phi_los
                             phi=phi_los-ang;   %1
                         else phi=ang-phi_los;%2
                         end
                else phi=2*pi+ang-phi_los;  %3
                end
            elseif phi_los<0
                     if ang<0
                         if ang>phi_los
                             phi=abs(phi_los)-abs(ang); %5
                         else phi=abs(phi_los)-abs(ang); %6
                         end
                     else phi=-2*pi-phi_los+ang; %4
                     end 
                 end
        else phi=ang-phi_los;
        end
        
        phi_dot=(phi-phi_alt)/timestep;     %winkel�nderung = (neuer winkel-alter winkel)/zeit
        phi_alt=phi;                        %neuer winkel wird zu altem winkel. 
        
        %Regler
        Kp=20;                              %empirisch ermittelte Regler-Parameter
        Kd=3;
        %Konstanten Schub tau_const vorgeben & rotatorischer Schub aus Regler berechnen:
        tau_const=5;
        tau_rot=-Kp*phi-Kd*phi_dot;
        
        %Kraft links und Kraft rechts ausrechnen: 
        Fr=(tau_const+tau_rot)*0.5;
        Fl=(tau_const-tau_rot)*0.5;
        %Leistungsbegrenzung f�r F. Zwischen 0 und 10 in diesem Fall
        if Fr<0
            Fr=0;
        end
        if Fl<0
            Fl=0;
        end
        if Fr>10
            Fr=10;
        end
        if Fl>10
            Fl=10;
        end

        %Sende Kraft an VREP
        vrep.simxSetFloatSignal(clientID,'data_right',Fr,vrep.simx_opmode_streaming);
        vrep.simxSetFloatSignal(clientID,'data_left',Fl,vrep.simx_opmode_streaming);
        
        %Speichern der Daten in allokierte Vektoren
        Kraft_rechts(t)=Fr;
        Kraft_links(t)=Fl;
        position_x(t)=pos_x;
        position_y(t)=pos_y;
        winkel(t)=ang;
        loswinkel(t)=phi_los;
        fehlerwinkel(t)=phi;

        pause(0.1)
        end
        vrep.simxPauseSimulation(clientID,vrep.simx_opmode_blocking);
        
        %�berfl�ssig allokierten Speicher entfernen
        position_x(t:end)=[];
        position_y(t:end)=[];
        Kraft_rechts(t:end)=[];
        Kraft_links(t:end)=[];
        winkel(t:end)=[];
        loswinkel(t:end)=[];
        fehlerwinkel(t:end)=[];
        zeit(t:end)=[];
        %Skalierungs-Anpassung
        zeit=zeit/10;
        
        %Position
        figure(1)
        subplot(2,2,1);
        plot(position_x,position_y,'r','LineWidth',2)
        hold on
        for k=1:sz(1)-1 %Liefert die Radien und die Strecke
            plot([A(k,1);A(k+1,1)],[A(k,2);A(k+1,2)],'b','DisplayName','Wegstrecke');
        end
        for k=1:sz(1)
            viscircles([A(k,1) A(k,2)],R_pkt,'EdgeColor','k','LineStyle','-','LineWidth',1);
        end
        grid on;
        axis([-1.5 6.5 -1.5 6.5])
        %title('2D-Ansicht der Fahrtregelung')
        xlabel('x in m')
        ylabel('y in m')
        %legend('Position des Schiffes','Wegstrecke','Location','bestoutside')
        hold off


        
        %Kr�fte
        subplot(2,2,2);
        fr_p=plot(zeit,Kraft_rechts,'r');      
        hold on;
        fl_p=plot(zeit,Kraft_links,'b');
        grid on;
        axis([0 t/10 -1 11 ])
        xlabel('t in s')
        ylabel('y in N')
        %title('Kraft-Zeit-Diagramm')     
        hold off
        %legend('Kraft rechts','Kraft links','Location','bestoutside')
        
        %Winkel
        subplot(2,2,[3,4]);
        plot(zeit,winkel,'b');              %Ausrichtungswinkel
        hold on;
        plot(zeit,loswinkel,'g');           %LOS-Winkel
        plot(zeit,fehlerwinkel,'r');        %Fehlerwinkel
        hold off;
        grid on;
        %legend('Ausrichtungswinkel','LOS-Winkel','Fehlerwinkel','Location','bestoutside')
        axis([0 t/10 -4 4 ]);
        xlabel('t in s')
        ylabel('y in rad')
        %title('Winkel-Zeit-Diagramm')

        
        % Simulation beenden und Verbindung zu VREP schlie�en :
        vrep.simxStopSimulation(clientID,vrep.simx_opmode_blocking);
        vrep.simxFinish(clientID);
    else
        disp('Failed connecting to remote API server');
    end
    %Destruktor 
    vrep.delete();
    
    disp('Programm wurde beendet');

end
