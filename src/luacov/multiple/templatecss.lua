return [[
    body {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
        font-size: 11pt;
    }
    h1 {
        font-weight: bold;
        font-size: 15pt;
    }
    a {
        color: #0074D9;
        text-decoration: none;        
    }
    .stats {
        display: inline;
        margin-right: 10pt;
    }
    .quiet {
        color: rgba(0,0,0,0.5);
    }
    .strong {
        font-weight: bold;
    }
    .status {
        margin-top: 10pt;
        height: 10px;
        margin-bottom: 10pt;
    }
    div[data-status='high'] {
        outline-color:rgb(77,146,33);
        background-color: rgb(77,146,33);
    }
    div[data-status='medium'] {
        outline-color: gray;
        background-color: gray;
    }
    div[data-status='low'] {
        outline-color: #C21F39;
        background-color: #C21F39;
    }
    .main {
        font-family: monospace;
        font-size: 10pt;
    }
    .numbers {
        float: left;
        color: silver;
        text-align: right;
    }
    .hits {
        color: gray;
        float: left;
        margin-left: 5pt;
        margin-right: 5pt;
        text-align: center;
        background-color: #eaeaea;
    }
    .line {
        padding-left: 5pt;
        padding-right: 5pt;
        white-space: pre;
    }
    .hits .line {
        background-color: rgb(230, 245, 208);
    }
    .line:empty {
        display: inline;
    }
    .line[data-hits='0'] {
        background-color: #FCE1E5;
    }
    .hits .line[data-hits='-'] {
        background-color: #eaeaea;
        color: silver;
    }
    .footer {
        text-align: center;
        padding: 25pt;
        font-size: 80%;
    }
    .chart {
        height: 12px;
        min-width: 120px !important;
        outline: 1px solid;
    }
    .chartfill {
        height: 12px;
        background-color: white;
        float: right;
    }
    table {
        display: table;
        border-collapse: collapse;
        border-spacing: 2px;
        border-color: grey;
        max-width: 1200px !important;
        width: 100%; 
        box-sizing: border-box;
    }
    th {
        border-right: none !important;
        text-align: left;
        font-weight: normal;
        white-space: nowrap;
        padding: 5pt;
    }
    td {
        padding: 5pt;
        border: 1px solid #bbb;
    }
    tr[data-status='high'] {
        background-color:rgb(230,245,208)
    }
    tr[data-status='medium'] {
        background-color: #EAEAEA;
    }
    tr[data-status='low'] {
        background-color: #FCE1E5;
    }
    .num {
        text-align: right;
    }
}}
]]
