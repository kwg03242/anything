function solve(width, height, columnHints, rowHints) {
    const answer = new Array(width * height).fill(0);
    
    const find = (a, b) =>{
        if (a === height) {return true;}

        answer[width * a + b] = 1;
        if(check(a, b)){
            if(find(b + 1 === width? a + 1 : a, b + 1 === width? 0 : b + 1))return true;
        }

        answer[width * a + b] = 0;
        if(check(a, b)){
            if(find(b + 1 === width? a + 1 : a, b + 1 === width? 0 : b + 1))return true;
        }
        
        return false;
    }

    function targetColumn(index){
        let column = new Array(height).fill().map((_, i) => answer[width * i + index]);
        return column;
    }

    function targetRow(index){
        let row = new Array(width).fill().map((_, i) => answer[width * index + i]);
        return row;
    }

    const check = (a, b) =>{
        return checkLine(columnHints[b], height, a + 1, targetColumn(b)) && checkLine(rowHints[a], width, b + 1, targetRow(a));
    }

    const checkLine = (hint, lengthLimit, length, getValueByIndex) =>{
        let hintIndex = 0;
        let currentLineLength = 0;
        let checked = false;
        for(let i = 0; i < length; i++){
            if(getValueByIndex[i]){
                currentLineLength++;
                if(!checked){
                    if(hintIndex >= hint.length)return false;
                }
                checked = true;
            }
            else { 
                if(checked){
                    if(hint[hintIndex] !== currentLineLength) return false;
                    currentLineLength = 0;
                    hintIndex++;
                }
                checked = false;
            }            
        }

        if(length === lengthLimit){
            if(checked) return hintIndex === hint.length - 1 && currentLineLength === hint[hintIndex];
            else return hintIndex === hint.length;
        }
        else {
            if(checked) return currentLineLength <= hint[hintIndex];
        }

        return true;
    }

    find(0, 0);

    return answer;
}


exports.default = solve;

console.log(solve(8, 6, [[4], [2], [2, 2], [6], [3, 2], [1,2], [2], [1,2]], [[3, 1], [1,4], [1,2,1], [1,1,2], [7], [5]]));