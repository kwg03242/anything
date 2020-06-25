import React, { useState, useEffect } from 'react';
import { TiDelete, TiEdit, TiArrowLeftThick, TiArrowRightThick, TiPlus } from "react-icons/ti";
import { btcTradeLogs } from '../promises/btcLogs';
import { tradeLogClass } from '../classes/logClass';
import { addTradeLog, modifyTradeLog, deleteTradeLog } from '../promises/tradeLogsRequests';

let defaultEditTrade = [];
for(let i = 0; i < 10; i++){
    defaultEditTrade.push({"date": null, "side": null, "volume": null});
}

const priceDateFormatting = (date) =>{
    let dateArray = date.split('-');
    let formattedDate = new Date(dateArray[0], dateArray[1] - 1, dateArray[2]);

    return formattedDate;
}

export default function TradeLog ( { tradeLogs = [], prices = [], refetchTradeLogs } ) {
    const [currentPage, setCurrentPage] = useState(0);
    const [maxPage, setMaxPage] = useState(0);
    const [tradeLogsDescending, setTradeLogsDescending] = useState([]);
    const [addTrade, setAddTrade] = useState({"date": null, "side": null, "volume": null});
    const [editTrade, setEditTrade] = useState({"date": null, "side": null, "volume": null});
    const [numberOfLogsPerPage, setNumberOfLogsPerPage] = useState(10);
    const [editIdx, setEditIdx] = useState(-1);
    const [startPoint, setStartPoint] = useState(new Date(0));
    const [endPoint, setEndPoint] = useState(new Date(Date.now()));
    const [startIdx, setStartIdx] = useState(0);
    const [endIdx, setEndIdx] =useState(0);

    useEffect (() => {
        setTradeLogsDescending(tradeLogs);
        setMaxPage(Math.floor((tradeLogs.length - 1) / numberOfLogsPerPage) + 1);
    }, [tradeLogs, numberOfLogsPerPage])

    useEffect(() => {
        if(prices.length > 0){
            setEndPoint(prices[prices.length - 1].date);
            setStartPoint(prices[0].date);
        }
    }, [prices])

    useEffect (() => {
        for(let i = 0; i < tradeLogsDescending.length; i++){
            if(tradeLogsDescending[i].date - endPoint <= 0){
                setStartIdx(i);
                break;
            }
        }

        for(let i = tradeLogsDescending.length - 1; i > -1; i--){
            if(tradeLogsDescending[i].date - startPoint >= 0){
                setEndIdx(i);
                break;
            }
        }       
    }, [startPoint, endPoint, tradeLogsDescending])

    useEffect(() => {
        setMaxPage(endIdx - startIdx >= 0 ? Math.ceil((endIdx - startIdx + 1) / numberOfLogsPerPage) : 0);
        setCurrentPage(0);
    }, [startIdx, endIdx, numberOfLogsPerPage])
    
    const onPrev = () =>{
        if(currentPage > 0){
            setCurrentPage((prevPage) => prevPage - 1);
        }
    }

    const onNext = () =>{
        if(currentPage < maxPage - 1){
            setCurrentPage((prevPage) => prevPage + 1);
        }
    }

    const onDelete = (idx) =>{
        if(window.confirm("삭제하시겠습니까?")){
            deleteTradeLog(idx)
            .then(
                btcTradeLogs()
                .then(() =>{
                    refetchTradeLogs();
                })
            )
        }
    }

    const onAdd = () =>{
        if(addTrade.date != null && addTrade.side != null && addTrade.volume != null){
            if(window.confirm("추가하시겠습니까?")){
                addTradeLog(new tradeLogClass (addTrade.date, addTrade.side, Number(addTrade.volume), "Bitcoin", 0))
                .then(() => {
                    refetchTradeLogs();
                })
            }
        }
        else {
            window.alert("invalidate data");
        }
    }

    const onDate = (date) =>{
        setAddTrade(prev => {prev.date = priceDateFormatting(date); return prev;})
    }

    const onEdit = (idx) =>{
        if(idx !== -1)setEditTrade(prev => {prev.date = tradeLogsDescending[idx].date; prev.side = tradeLogsDescending[idx].side; prev.volume = tradeLogsDescending[idx].volume; return prev;})
        setEditIdx(idx);
    }

    const onEditDate = (date) =>{
        setEditTrade(prev => {prev.date = priceDateFormatting(date); return prev;})
    }

    const onEditConfirm = (e) =>{
        e.preventDefault();
        if(window.confirm("수정하시겠습니까?")){
            if(editTrade.date !== null && editTrade.side !== '' && editTrade.volume !== null && !isNaN(editTrade.volume) && editTrade.volume[0] !== '-'){
                modifyTradeLog(new tradeLogClass(editTrade.date, editTrade.side, Number(editTrade.volume), "Bitcoin", 0), Number(e.target.value))
                .then(res => {
                    refetchTradeLogs();
                    setEditIdx(-1);
                })
            }
            else {
                window.alert("invalidate data");
            }
        }
    }  

    return (
        <>
            <section className="background">
                <div className="trade-log-wrapper">
                    <div className="title">매매 기록</div>
                    <div className="row">
                        <label>표시 개수 
                            <select onChange={(e) => {
                                if(currentPage * Number(e.target.value) > endIdx){setCurrentPage(Math.floor((tradeLogsDescending.length - 1) / Number(e.target.value)))};
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
                                <label>조회 시작 날짜 
                                    <input type="date" onChange={e => {setStartPoint(e.target.value? priceDateFormatting(e.target.value) : prices[0].date);}} defaultValue={dateToISOString(prices[0].date)} min={dateToISOString(prices[0].date)} max={dateToISOString(endPoint)} />
                                </label>
                                <label>조회 마지막 날짜
                                    <input type="date" onChange={e => {setEndPoint(e.target.value? priceDateFormatting(e.target.value) : prices[prices.length - 1].date);}} defaultValue={dateToISOString(prices[prices.length - 1].date)} min={dateToISOString(startPoint)} max={dateToISOString(prices[prices.length - 1].date)} />
                                </label>
                            </>
                        }
                    </div>
                    <ul>
                        {tradeLogsDescending.length > 0 &&
                            tradeLogsDescending.slice(startIdx + currentPage * numberOfLogsPerPage, startIdx + currentPage * numberOfLogsPerPage + numberOfLogsPerPage > endIdx? endIdx + 1: startIdx + currentPage * numberOfLogsPerPage + numberOfLogsPerPage).map((log) => {
                                let idx = log.idx;
                                return (
                                    <>
                                        {idx !== editIdx &&
                                            <div className="row">
                                                {log.print()}
                                                <div onClick={() => onDelete(idx)} className="pointer"><TiDelete /></div>
                                                <div onClick={() => onEdit(idx)} className="pointer"><TiEdit /></div>
                                            </div>
                                        }
                                        {idx === editIdx &&
                                            <div className="row">
                                                <form>
                                                    <input type="date" onChange={e => {onEditDate(e.target.value);}} defaultValue={dateToISOString(tradeLogsDescending[idx].date)} min={dateToISOString(prices[0].date)} max={dateToISOString(prices[prices.length - 1].date)} />
                                                    <select onChange={e => {let value = e.target.value; setEditTrade(prev => {prev.side = value; return prev;});}} defaultValue={tradeLogsDescending[idx].side}>
                                                        <option value="">거래내용</option>
                                                        <option value="buy">구매</option>
                                                        <option value="sell">판매</option>
                                                    </select>
                                                    <input type="text" onChange={e => {let value = e.target.value; setEditTrade(prev => {prev.volume = value; return prev;});}} size="6" defaultValue={tradeLogsDescending[idx].volume}/>
                                                </form>
                                                <button onClick={onEditConfirm} value={idx}>확인</button>
                                                <button onClick={() => onEdit(-1)}>취소</button>
                                            </div>
                                        }
                                    </>
                                );
                            })
                        }
                        {tradeLogsDescending.length === 0 &&
                            <div>거래 내역이 없습니다.</div>
                        }
                    </ul>
                    <div className="row">
                        <div onClick={onPrev} className="pointer"><TiArrowLeftThick /></div>
                        <div onClick={onNext} className="pointer"><TiArrowRightThick /></div>
                    </div>
                    <form>
                        <div className="row">
                            <label>날짜:</label>
                            {prices.length > 0 &&
                                <>
                                    <input onChange={e => onDate(e.target.value)} type="date" min={dateToISOString(prices[0].date)} max={dateToISOString(prices[prices.length - 1].date)} />
                                    <label>거래내용:</label>
                                    <select onChange={(e) => {let value = e.target.value; setAddTrade(prev => {prev.side = value; return prev;})}}>
                                        <option value="">거래내용</option>
                                        <option value="buy">구매</option>
                                        <option value="sell">판매</option>
                                    </select>
                                    <label>개수:</label>
                                    <input type="text" onChange={(e) => {let value = e.target.value; setAddTrade(prev => {prev.volume = Number(value); return prev;})}} size="6" />
                                    <div className="pointer" onClick={onAdd}><TiPlus /></div>
                                </>
                            }
                        </div>
                    </form>
                </div>
            </section>
        </>
    );
}

const dateToISOString = (date) =>{
    let out = new Date(date.getFullYear(), date.getMonth(), date.getDate() + 1);
    return out.toISOString().slice(0, 10);
}