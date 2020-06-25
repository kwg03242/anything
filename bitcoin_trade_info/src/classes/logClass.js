import React from 'react';
import { coinToUnit } from '../functions/coinToUnit'

export class tradeLogClass {
    constructor (time, side, volume, coin, idx){
        this.date = time;
        this.side = side;
        this.volume = volume;
        this.coin = coin;
        this.idx = idx;
    }
  
    print() {
        return (
            <li className="trade-log">
                <div className="trade-log-date">{dateToISOString(this.date).slice(0, 10)}</div>
                <div className="trade-log-side">{this.side}</div> 
                <div className="trade-log-volume">{this.volume} {coinToUnit(this.coin)}</div>
            </li>
        );
    }
}

export class priceLogClass {
    constructor (date, coin, price, volume){
        this.date = date;
        this.coin = coin;
        this.price = parseInt(price, 10);
        this.volume = volume;
    }
    
    print = () => {
        return (
            <li>
                {this.date.getFullYear()}.{this.date.getMonth() + 1}.{this.date.getDate()} {this.price} {this.volume}
            </li>
        );
    }
}

export class profitClass {
    constructor (date, btc, cash, profit){
        this.date = date;
        this.btc = btc;
        this.cash = cash;
        this.profit = profit;
    }

    print = () => {
        return (
                <li className="profit-form">
                    <div className="date-of-profit">{dateToISOString(this.date).slice(0, 10)}</div>
                    <div className="btc-of-profit">보유 Bitcoin: {new Intl.NumberFormat().format(this.btc)} BTC</div>
                    <div className="usd-of-profit">보유 현금: {new Intl.NumberFormat().format(this.cash)} $</div>
                    <div className="profit-of-profit">Profit: {new Intl.NumberFormat().format(this.profit)} $</div>
                </li>
        );
    }
}

const dateToISOString = (date) =>{
    let out = new Date(date.getFullYear(), date.getMonth(), date.getDate() + 1);
    return out.toISOString().slice(0, 10);
}