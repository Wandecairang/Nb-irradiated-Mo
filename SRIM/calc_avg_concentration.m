function [avgConc, areaVal, thickness] = calc_avg_concentration(filename)
% 计算浓度随深度变化曲线的平均浓度（直到浓度降为0）
% filename : Excel 文件名（如 'Concentration with depth.xlsx'）

    % 读取 Excel
    data = readmatrix(filename);
    x = data(:,1);   % 假设第一列是深度
    y = data(:,2);   % 假设第二列是浓度

    % 按深度排序（防止乱序）
    [x, idx] = sort(x);
    y = y(idx);

    % 找到浓度第一次降到零的位置
    endpointX = x(end);
    for i = 1:length(y)-1
        if y(i) > 0 && y(i+1) <= 0
            % 线性插值求精确零点
            t = (0 - y(i)) / (y(i+1) - y(i));
            endpointX = x(i) + t * (x(i+1) - x(i));
            break
        end
    end

    % 截断数据
    mask = x <= endpointX;
    x_trunc = x(mask);
    y_trunc = y(mask);

    % 如果终点不是原始点，则补插值点
    if x_trunc(end) < endpointX
        x_trunc(end+1) = endpointX;
        y_trunc(end+1) = 0;
    end

    % 积分（梯形法）
    areaVal = trapz(x_trunc, y_trunc);
    thickness = x_trunc(end) - x_trunc(1);
    avgConc = areaVal / thickness;

    % 打印结果
    fprintf('深度区间: %.3f → %.3f (厚度 = %.3f)\n', x_trunc(1), x_trunc(end), thickness);
    fprintf('积分面积 (浓度×深度): %.3f\n', areaVal);
    fprintf('平均浓度: %.3f\n', avgConc);

    % 作图
    figure;
    plot(x, y, '-b','LineWidth',1.5); hold on;
    area(x_trunc, y_trunc, 'FaceColor',[0.7 0.7 1],'FaceAlpha',0.5);
    plot(endpointX, 0, 'ro','MarkerFaceColor','r');
    xlabel('Depth');
    ylabel('Concentration');
    title('Concentration vs Depth');
    legend('原始曲线','积分区间','终点 (浓度=0)','Location','Best');
    grid on;
end
