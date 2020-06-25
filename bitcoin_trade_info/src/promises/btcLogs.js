export function btcTradeLogs() {
    return (
        new Promise((resolve, reject) => {
            setTimeout(() =>{
                if(localStorage.getItem("tradeLogs"))resolve(localStorage.getItem("tradeLogs"));
                else {
                    let logs = JSON.stringify(require('../data/trade_log.json').reverse());
                    localStorage.setItem("tradeLogs", logs);
                    resolve(logs);
                }
            }, 300)
        })
    );
}

export function btcValueLogs() {
    return (
        new Promise((resolve, reject) => {
            setTimeout(() =>{
                resolve(JSON.stringify(require('../data/bitcoin_price.json')));
            }, 300)
        })
    );
}