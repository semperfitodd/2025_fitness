import React from 'react';
import { BarElement, CategoryScale, Chart as ChartJS, Legend, LinearScale, Title, Tooltip } from 'chart.js';
import { Bar } from 'react-chartjs-2';
import { chartOptions } from '../utils/chartConfig';
import { FITNESS_CONSTANTS, CHART_COLORS } from '../utils/constants';
import { useDateCalculations } from '../hooks/useDateCalculations';

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend);

// Custom plugin to add percentage labels inside bars
const percentageLabelPlugin = {
    id: 'percentageLabels',
    afterDraw: (chart) => {
        const { ctx, data } = chart;
        
        data.datasets.forEach((dataset, datasetIndex) => {
            dataset.data.forEach((value, index) => {
                const meta = chart.getDatasetMeta(datasetIndex);
                const element = meta.data[index];
                
                if (element) {
                    const { x: barX, y: barY, width: barWidth, height: barHeight } = element;
                    
                    // Calculate position for the label (inside the bar)
                    const labelX = barX + (barWidth / 2);
                    const labelY = barY + (barHeight / 2);
                    
                    // Format the percentage
                    const percentage = value.toFixed(1) + '%';
                    
                    // Set text style
                    ctx.save();
                    ctx.textAlign = 'center';
                    ctx.textBaseline = 'middle';
                    ctx.font = 'bold 14px Inter, sans-serif';
                    
                    // Add text shadow for better visibility
                    ctx.shadowColor = 'rgba(0, 0, 0, 0.8)';
                    ctx.shadowBlur = 4;
                    ctx.shadowOffsetX = 1;
                    ctx.shadowOffsetY = 1;
                    
                    // Draw the percentage label
                    ctx.fillStyle = '#ffffff';
                    ctx.fillText(percentage, labelX, labelY);
                    
                    ctx.restore();
                }
            });
        });
    }
};

// Register the custom plugin
ChartJS.register(percentageLabelPlugin);

const ProgressBarGraph = ({ totalLifted }) => {
    const { daysIntoYear, daysIntoYearPercentage } = useDateCalculations();

    // Calculate percentages
    const totalLiftedPercentage = Math.round((totalLifted / FITNESS_CONSTANTS.YEARLY_GOAL_LBS) * 100 * 100) / 100;

    // Data object passed to the chart with enhanced styling
    const data = {
        labels: ['Total Lifted', 'Days Into Year'],
        datasets: [
            {
                label: 'Progress (%)',
                data: [totalLiftedPercentage, daysIntoYearPercentage],
                backgroundColor: [
                    'linear-gradient(90deg, #FFD700, #FFA500)',
                    'linear-gradient(90deg, #FF6B6B, #FF8E8E)'
                ],
                borderColor: [CHART_COLORS.PROGRESS_YELLOW_BORDER, CHART_COLORS.PROGRESS_RED_BORDER],
                borderWidth: 2,
                borderRadius: 8,
                borderSkipped: false,
                hoverBackgroundColor: [
                    'linear-gradient(90deg, #FFED4E, #FFB347)',
                    'linear-gradient(90deg, #FF8A80, #FFB3BA)'
                ],
                hoverBorderWidth: 3,
                hoverBorderColor: ['#FFD700', '#FF6B6B'],
            },
        ],
    };



    // Updated chart options with improved visibility and responsive design
    const updatedChartOptions = {
        ...chartOptions,
        scales: {
            x: {
                min: 0,
                max: 100,
                ticks: {
                    color: '#b0b0b0',
                    font: {
                        size: 12
                    }
                },
                grid: {
                    color: '#2a2a3e'
                }
            },
            y: {
                ticks: {
                    color: '#b0b0b0',
                    font: {
                        size: 14,
                        weight: '600'
                    },
                    padding: 10
                },
                grid: {
                    display: false
                }
            }
        },
        plugins: {
            legend: {
                display: false // Remove legend
            },
            tooltip: {
                backgroundColor: '#16213e',
                titleColor: '#ffffff',
                bodyColor: '#b0b0b0',
                borderColor: '#e94560',
                borderWidth: 1,
                cornerRadius: 8,
                callbacks: {
                    label: (context) => {
                        const value = context.raw.toFixed(2);
                        if (context.label === 'Days Into Year') {
                            return `${context.label}: ${value}% of the year completed (${daysIntoYear} days)`;
                        }
                        if (context.label === 'Total Lifted') {
                            return `${context.label}: ${value}% of goal lifted (${totalLifted.toLocaleString()} lbs)`;
                        }
                        return `${context.label}: ${value}%`;
                    },
                },
            },
        },
        indexAxis: 'y',
        responsive: true,
        maintainAspectRatio: false,
        layout: {
            padding: {
                left: 20,
                right: 20,
                top: 20,
                bottom: 20
            }
        },
        animation: {
            duration: 2000,
            easing: 'easeOutQuart',
            onProgress: function(animation) {
                // Add a subtle glow effect during animation
                const chart = animation.chart;
                const ctx = chart.ctx;
                ctx.shadowColor = 'rgba(255, 215, 0, 0.3)';
                ctx.shadowBlur = 10;
            },
            onComplete: function(animation) {
                // Remove glow effect after animation
                const chart = animation.chart;
                const ctx = chart.ctx;
                ctx.shadowBlur = 0;
            }
        },
        transitions: {
            active: {
                animation: {
                    duration: 400,
                    easing: 'easeOutQuart'
                }
            }
        }
    };

    return (
        <div className="chart-container">
            <Bar data={data} options={updatedChartOptions} />
        </div>
    );
};

export default ProgressBarGraph;
