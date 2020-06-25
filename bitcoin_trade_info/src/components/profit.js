import React, { useState, useEffect } from 'react';
import { profitClass } from '../classes/logClass'
import { LineChart } from './lineChart';
import { TiDelete, TiEdit, TiArrowLeftThick, TiArrowRightThick, TiPlus } from "react-icons/ti";

const millisecPerDay = 1000 * 60 * 60 * 24;
const unitTime = millisecPerDay;

export default function Profit( { logs = [], prices = [] } ) {
    var cloneDeep = require('lodash.clonedeep');
    const initialCash = 0;
    const initialBtc = 40;
    const [profits, setProfits] = useState([]);
    const [chartData, setChartData] = useState([]);
    const [currentBtc, setCurrentBtc] = useState(initialBtc);
    const [currentCash, setCurrentCash] = useState(initialCash);
    const [isProfitsOpen, setIsProfitsOpen] = useState(false);
    const [isProfitChartOpen, setIsProfitChartOpen] = useState(false);
    const [profitsPage, setProfitsPage] = useState(0);
    const [maxProfitsPage, setMaxProfitsPage] = useState(0);
    const [numberOfLogsPerPage, setNumberOfLogsPerPage] = useState(10);
    const [startPoint, setStartPoint] = useState(new Date(0));
    const [endPoint, setEndPoint] = useState(new Date(0));
    const [startIdx, setStartIdx] = useState(0);
    const [endIdx, setEndIdx] = useState(-1);
    const [rangedProfit, setRangedProfit] = useState([]);

    useEffect(() => {
        let sortedLogs = cloneDeep(logs);
        sortedLogs.reverse();
        let cash = currentCash;
        let btc = currentBtc;
        let duration = 0;
        let profits = [];

        if(prices.length > 0){
            setStartPoint(prices[0].date);
            setEndPoint(prices[prices.length - 1].date);
        }

        if(prices.length){
            duration = (prices[prices.length - 1].date - prices[0].date + 1)/unitTime;
        }

        let j = 0;
        let i = 0;
        
        for(let k = 0; k < duration; k++){
            while(sortedLogs.length > j && sortedLogs[j].date.getTime() === prices[i].date.getTime()){
                if(sortedLogs[j].side === 'sell'){
                    btc = btc - sortedLogs[j].volume;
                    cash = cash + sortedLogs[j].volume * prices[i].price;
                }
                else if(sortedLogs[j].side === 'buy'){
                    btc = btc + sortedLogs[j].volume;
                    cash = cash - sortedLogs[j].volume * prices[i].price;
                }
                j++;
            }

            profits.push(new profitClass(prices[i].date, btc, cash, btc * prices[i].price + cash - initialBtc * prices[0].price - initialCash));
            if(prices[i].date.getTime() === prices[0].date.getTime() + k * unitTime)i++;
        }
        console.log(1);
        setProfits(profits);
        setChartData(profits.map(profit => {return {"date": profit.date, "price": profit.profit}}))
        setMaxProfitsPage(Math.ceil(profits.length / 10));
    }, [logs, prices])
    
    useEffect (() => {
        for(let i = 0; i < profits.length; i++){
            if(profits[i].date - startPoint >= 0){
                setStartIdx(i);
                break;
            }
        }

        for(let i = profits.length - 1; i > -1; i--){
            if(profits[i].date - endPoint <= 0){
                setEndIdx(i);
                break;
            }
        }       
        console.log(2);
    }, [startPoint, endPoint, profits])

    useEffect(() => {
        let rangedProfits = [];
        let initProfit = profits[startIdx];
        for(let i = 0; i < endIdx - startIdx + 1; i++){
            rangedProfits.push(new profitClass(profits[i + startIdx].date, profits[i + startIdx].btc, profits[i + startIdx].cash, profits[i + startIdx].profit - initProfit.profit))
        }
        setChartData(rangedProfits.map(rangedProfit => {return {"date": rangedProfit.date, "price": rangedProfit.profit}}))
        console.log(rangedProfits);
        setMaxProfitsPage(endIdx - startIdx >= 0 ? Math.ceil((endIdx - startIdx + 1) / numberOfLogsPerPage) : 0);
        setRangedProfit(rangedProfits);
        setProfitsPage(0);
    }, [startIdx, endIdx, numberOfLogsPerPage, profits])

    console.log(rangedProfit);

    return (
        <>
            <section className="chart-section">
                <button onClick={() => setIsProfitsOpen(prev => !prev)} className="button">{isProfitsOpen? `손익표 닫기` : `손익표 열기`}</button>
                <div className={isProfitsOpen? "fadeIn":"fadeOut"}>
                    <div className="row">
                        <label>표시 개수 
                            <select onChange={(e) => {
                                if(profitsPage * Number(e.target.value) > endIdx){setProfitsPage(Math.floor((profits.length - 1) / Number(e.target.value)))};
                                setNumberOfLogsPerPage(Number(e.target.value));
                            }}>
                                <option value={5}>5개</option>
                                <option value={10} selected>10개</option>
                                <option value={15}>15개</option>
                                <option value={20}>20개</option>
                            </select>
                        </label>
                        {prices.length > 0 &&
                            <>
                                <label>기준 날짜 
                                    <input type="date" onChange={e => {setStartPoint(e.target.value? priceDateFormatting(e.target.value) : prices[0].date);}} defaultValue={dateToISOString(prices[0].date)} min={dateToISOString(prices[0].date)} max={dateToISOString(endPoint)} />
                                </label>
                                <label>조회 마지막 날짜
                                  <input type="date" onChange={e => {setEndPoint(e.target.value? priceDateFormatting(e.target.value) : prices[prices.length - 1].date);}} defaultValue={dateToISOString(prices[prices.length - 1].date)} min={dateToISOString(startPoint)} max={dateToISOString(prices[prices.length - 1].date)} />
                                </label>
                            </>
                        }
                    </div>
                    {
                        rangedProfit.slice(rangedProfit.length - numberOfLogsPerPage * (profitsPage + 1) < 0? 0 : rangedProfit.length - numberOfLogsPerPage * (profitsPage + 1), rangedProfit.length - numberOfLogsPerPage * profitsPage).reverse().map(profit => profit.print())
                    }
                    <div className="row">
                        <div onClick={() => setProfitsPage(prev => prev > 0? prev - 1 : 0)} className="pointer"><TiArrowLeftThick /></div>
                        <div onClick={() => setProfitsPage(prev => prev < maxProfitsPage - 1 ? prev + 1 : maxProfitsPage - 1)} className="pointer"><TiArrowRightThick /></div>
                    </div>
                </div>
            </section>
            <section className="chart-section">
                    <button onClick={() => setIsProfitChartOpen(prev => !prev) } className="button">{isProfitChartOpen? `손익 차트 닫기` : `손익 차트 열기`}</button>
                    <div className="center">
                        <div className={isProfitChartOpen? "fadeIn":"fadeOut"}>
                            <LineChart logs={chartData} text="수익" width={isProfitChartOpen? 800 : 0} height={isProfitChartOpen? 350 :0}/>
                        </div>
                    </div>
            </section>
        </>
    );
}

const dateToISOString = (date) =>{
    let out = new Date(date.getFullYear(), date.getMonth(), date.getDate() + 1);
    return out.toISOString().slice(0, 10);
}

const priceDateFormatting = (date) =>{
    let dateArray = date.split('-');
    let formattedDate = new Date(dateArray[0], dateArray[1] - 1, dateArray[2]);

    return formattedDate;
}                        
/* (profits.slice(endIdx + 1 - numberOfLogsPerPage * (profitsPage + 1) < startIdx? startIdx : endIdx + 1 - numberOfLogsPerPage * (profitsPage + 1), endIdx + 1 - numberOfLogsPerPage * profitsPage)).reverse().map(profit => profit.print()) */
