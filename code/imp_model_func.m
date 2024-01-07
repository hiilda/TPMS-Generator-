function [F,V] = imp_model_func(app,out_p,x1,y1,z1,cell_len_x,cell_len_y,...
    cell_len_z,app_t,isovalue,lattice_type,structure_type,volumeFill,custom_function)
 %check if app fored termination
drawnow;
if app.stopFlag
    return
end

switch volumeFill
    case "Fill Above Isovalue"
        volumeFill = 'above';
    case "Fill Below Isovalue"
        volumeFill = 'below';
    otherwise 
end

f = tpms_function(app,x1,y1,z1,lattice_type,custom_function); %gets the value of f for corresponding tpms structure

switch structure_type
    case "Sheet"
        f(out_p == 0) = 1e10;       %redefine level set field based in case of arbitrary geometry
        isovalue = app_t/2;
        h = (f-isovalue).*-(f+isovalue);

        drawnow;
        if app.stopFlag
            return
        end

        [face1, vertex1] = isosurface(x1,y1,z1,h,0);    %creates isosurface

        drawnow;
        if app.stopFlag
            return
        end

        [face2, vertex2] = isocaps(x1,y1,z1,h,0);       %creates endcaps

    case "Solid"
        f(out_p == 0) = -1e10;
        h = f+isovalue;

        drawnow;
        if app.stopFlag
            return
        end

        [face1, vertex1] = isosurface(x1,y1,z1,h,0);

        drawnow;
        if app.stopFlag
            return
        end

        [face2, vertex2] = isocaps(x1,y1,z1,h,0, volumeFill );
end

drawnow;
if app.stopFlag
    return
end

F = [face1; length(vertex1(:,1)) + face2]; %concatenates the face arrays which represent the faces of the resulting Solid
V = [vertex1; vertex2]; %concatenates the vertex arrays which represent the vertices of the resulting Solid
V = [V(:,1)*cell_len_x, V(:,2)*cell_len_y, V(:,3)*cell_len_z];
