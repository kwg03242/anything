import React, { useState, useEffect } from 'react';
import TradeLog from './components/tradeLog';
import Profit from './components/profit';
import './components/general.css'
import './App.css';
import { LineChart } from './components/lineChart'
import { priceLogClass, tradeLogClass } from './classes/logClass'
import { btcValueLogs, btcTradeLogs } from './promises/btcLogs';

const priceDateFormatting = (date) =>{
  let dateArray = date.split('-');
  let formattedDate = new Date(dateArray[0], dateArray[1] - 1, dateArray[2]);

  return formattedDate;
}

const tradeLogDateFormatting = (date) =>{
  let timeArray = date.split('/');
  let formattedDate = new Date(timeArray[2], timeArray[0] - 1, timeArray[1]);

  return formattedDate;
}

function App() {
  const [pricesOfBitcoin, setPriceOfBitcoin] = useState([]);
  const [openChart, setOpenChart] = useState(true);
  const [tradeLogs, setTradeLogs] = useState([]);

  useEffect(() =>{
    btcValueLogs()
    .then(res =>{
      let priceData = JSON.parse(res);
      let sortedBitcoinPrices = priceData.map((log) => new priceLogClass(priceDateFormatting(log.Date), log.Coin, log.Price, log.Volume));
      sortedBitcoinPrices.sort((a, b) => a.date - b.date);
      setPriceOfBitcoin(sortedBitcoinPrices);
    })

    btcTradeLogs()
    .then(res =>{
      let tradeLogs;
      let unpagedLogs;
      tradeLogs = JSON.parse(res);
      let i = 0;
      unpagedLogs = tradeLogs.map((log) => new tradeLogClass(tradeLogDateFormatting(log.time), log.side, log.volume, "Bitcoin", i++));

      setTradeLogs(unpagedLogs);
    })
  }, [])

  const refetchTradeLogs = () =>{
    btcTradeLogs()
    .then(res =>{
        let sortedLogs = JSON.parse(res);
        let i = 0;
        setTradeLogs(sortedLogs.map((log) => new tradeLogClass(tradeLogDateFormatting(log.time), log.side, log.volume, "Bitcoin", i++)));
    })
}

  return (
    <>
      <section className="menu-section">
        <h2 className="head">Bitcoin Trading Info</h2>
      </section>
      <section className="chart-section">
        <button onClick={() => setOpenChart(prev => !prev)} className="button">{openChart? `Bitcoin 차트 닫기` : `Bitcoin 차트 열기`}</button>
        <div className="center">
          <div className={openChart? "fadeIn":"fadeOut"}>
            <LineChart logs={pricesOfBitcoin} text="USD/BTC" width={openChart? 800 : 0} height={openChart? 350 :0}/>
          </div>
        </div>
      </section>
      <TradeLog prices={pricesOfBitcoin} tradeLogs={tradeLogs} refetchTradeLogs={refetchTradeLogs}/>
      <Profit logs={tradeLogs} prices={pricesOfBitcoin} />
    </>
  );
}

export default App;