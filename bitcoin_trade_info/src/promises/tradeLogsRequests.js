import { tradeLogClass } from '../classes/logClass';

const tradeLogDateFormatting = (date) =>{
        let timeArray = date.split('/');
        let formattedDate = new Date(timeArray[2], timeArray[0] - 1, timeArray[1]);
    
        return formattedDate;
}

export function addTradeLog (log){
    return (
        new Promise((resolve, reject) => {
            setTimeout(() =>{
                let logsJSON = JSON.parse(localStorage.getItem("tradeLogs"));

                let logs = logsJSON.map(log => new tradeLogClass(tradeLogDateFormatting(log.time), log.side, log.volume, "Bitcoin", 0));
                logs.push(log);
                logs.sort((a, b) => b.date - a.date);

                for(let i = 0; i < logs.length; i++){
                    logs[i].idx = i;
                }

                let formattedLogs = logs.map(log => {
                    return {"time": `${log.date.getMonth() + 1}/${log.date.getDate()}/${log.date.getFullYear()}`, "side": log.side, "volume": log.volume};
                });

                localStorage.setItem("tradeLogs", JSON.stringify(formattedLogs));
                
                resolve("success");
            }, 300)
        })
    )
}

export function modifyTradeLog (log, idx){
    return (
        new Promise((resolve, reject) => {
            setTimeout(() =>{
                let logsJSON = JSON.parse(localStorage.getItem("tradeLogs"));

                let logs = logsJSON.map(log => new tradeLogClass(tradeLogDateFormatting(log.time), log.side, log.volume, "Bitcoin", 0));
                logs[idx] = log;
                logs.sort((a, b) => b.date - a.date);

                for(let i = 0; i < logs.length; i++){
                    logs[i].idx = i;
                }

                let formattedLogs = logs.map(log => {
                    return {"time": `${log.date.getMonth() + 1}/${log.date.getDate()}/${log.date.getFullYear()}`, "side": log.side, "volume": log.volume};
                });

                localStorage.setItem("tradeLogs", JSON.stringify(formattedLogs));
                
                resolve("success");
            }, 300)
        })
    )
}

export function deleteTradeLog (idx){
    return (
        new Promise((resolve, reject) => {
            setTimeout(() =>{
                let logsJSON = JSON.parse(localStorage.getItem("tradeLogs"));

                let logs = logsJSON.map(log => new tradeLogClass(tradeLogDateFormatting(log.time), log.side, log.volume, "Bitcoin", 0));
                logs.splice(idx, 1);
                logs.sort((a, b) => b.date - a.date);

                for(let i = 0; i < logs.length; i++){
                    logs[i].idx = i;
                }

                let formattedLogs = logs.map(log => {
                    return {"time": `${log.date.getMonth() + 1}/${log.date.getDate()}/${log.date.getFullYear()}`, "side": log.side, "volume": log.volume};
                });

                localStorage.setItem("tradeLogs", JSON.stringify(formattedLogs));
                
                resolve("success");
            }, 300)
        })
    )
}