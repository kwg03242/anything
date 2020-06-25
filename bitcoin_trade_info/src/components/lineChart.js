import React, { useState, useEffect } from 'react';
import ReactApexChart from 'react-apexcharts';

export function LineChart( { logs = [], text = '', width = 800, height = 350 } ) {
    let data = [];

    const [btcData, setBtcData] = useState([{
        name: 'USD/BTC',
        data: data
    }]);

    const [optionOfBTCChart, setOptionOfBTCChart] = useState({
        chart: {
          type: 'line',
          stacked: false,
          height: 350,
          zoom: {
            type: 'x',
            enabled: true,
            autoScaleYaxis: true,
          },
          toolbar: {
            autoSelected: 'zoom',
            tools: {
              download: false,
            },
          },
        },

        dataLabels: {
          enabled: false
        },

        markers: {
          size: 0,
        },

        colors: ['#546E7A'],

        title: {
          text: text,
          align: 'left'
        },

        yaxis: { 
          title: {
            text: '$'
          },
        },

        xaxis: {
          type: 'datetime',
        },

        tooltip: {
          shared: false,
        }
    });

    useEffect(() =>{
        logs.map((log) => data.push({x: log.date, y: Math.floor(log.price)}));
        setBtcData(
            [{
                name: text,
                data: data
            }]
        )
        setOptionOfBTCChart({
          chart: {
            type: 'line',
            stacked: false,
            height: 350,
            zoom: {
              type: 'x',
              enabled: true,
              autoScaleYaxis: true,
            },
            toolbar: {
              autoSelected: 'zoom',
              tools: {
                download: false,
              },
            },
          },
  
          dataLabels: {
            enabled: false
          },
  
          markers: {
            size: 0,
          },
  
          colors: ['#546E7A'],
  
          title: {
            text: text,
            align: 'left'
          },
  
          yaxis: { 
            title: {
              text: '$'
            },
          },
  
          xaxis: {
            type: 'datetime',
          },
  
          tooltip: {
            shared: false,
          }
      })
    }, [logs, text])

    return (
        <div id="chart">
            <ReactApexChart options={optionOfBTCChart} series={btcData} type="line" height={height} width={width} />
        </div>
    );
}