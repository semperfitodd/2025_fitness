import React from 'react';
import {BarElement, CategoryScale, Chart as ChartJS, Legend, LinearScale, Title, Tooltip,} from 'chart.js';
import {Bar} from 'react-chartjs-2';
import {chartOptions} from '../utils/chartConfig';

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend);

const ProgressBarGraph = ({totalLifted, daysIntoYear}) => {
    const totalLiftedPercentage = (totalLifted / 15000000) * 100;
    const daysIntoYearPercentage = (daysIntoYear / 365) * 100;

    const data = {
        labels: ['Total Lifted', 'Days Into Year'],
        datasets: [
            {
                label: 'Progress (%)',
                data: [totalLiftedPercentage, daysIntoYearPercentage],
                backgroundColor: ['#FFFF00', '#FF0000'],
                borderColor: ['#B2B200', '#B20000'],
                borderWidth: 1,
            },
        ],
    };

    return (
        <div className="chart-container">
            <Bar data={data} options={{...chartOptions, indexAxis: 'y'}}/>
        </div>
    );
};

export default ProgressBarGraph;
