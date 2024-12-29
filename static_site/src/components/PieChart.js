import React from 'react';
import {ArcElement, Chart as ChartJS, Legend, Tooltip,} from 'chart.js';
import {Pie} from 'react-chartjs-2';
import {chartOptions, colorPalette} from '../utils/chartConfig';

ChartJS.register(ArcElement, Tooltip, Legend);

const PieChart = ({exercises}) => {
    const data = {
        labels: Object.keys(exercises),
        datasets: [
            {
                data: Object.values(exercises),
                backgroundColor: colorPalette.slice(0, Object.keys(exercises).length),
                borderWidth: 1,
            },
        ],
    };

    return (
        <div className="chart-container">
            <Pie data={data} options={chartOptions}/>
        </div>
    );
};

export default PieChart;
