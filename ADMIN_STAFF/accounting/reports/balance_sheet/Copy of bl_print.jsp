<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<%@ page language="java" import="utility.*,Accounting.Report.ReportGeneric, java.util.Vector" %>
<%
	WebInterface WI  = new WebInterface(request);
	DBOperation dbOP = null;
	
	String strTemp   = null;
	String strErrMsg = null;
	
//add security here.
	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.

ReportGeneric rg  = new ReportGeneric();
Vector vRetResult = rg.getBalanceSheet(dbOP, request);
if(vRetResult == null)
	strErrMsg = rg.getErrMsg();
System.out.println(strErrMsg);
%>
<body >
<form>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25"><div align="right">Page $page_num</div></td>
    </tr>
    <tr> 
      <td height="25"><div align="center"> 
          <p><strong>CENTRAL 
            PHILIPPINE UNIVERSITY</strong><br>Jaro, Iloilo City</p>
        </div></td>
    </tr>
    <tr> 
      <td height="50"><div align="center"><strong><u>BALANCE SHEET <br>
          </u></strong>$date</div></td>
    </tr>
    <tr>
      <td height="24"><div align="center"><strong>A S S E T S</strong></div></td>
    </tr>
    <tr> 
      <td height="10"></td>
    </tr>
  </table>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="2%" height="18">1</td>
      <td height="18" colspan="8">A S S E T S</td>
    </tr>
    <tr> 
      <td height="18">2</td>
      <td height="18" colspan="3">&nbsp;A. GENERAL FUND</td>
      <td width="14%" height="18">&nbsp;</td>
      <td width="3%" height="18">&nbsp;</td>
      <td width="14%" height="18">&nbsp;</td>
      <td width="2%" height="18">&nbsp;</td>
      <td width="17%" height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18"><div align="left">3&nbsp;&nbsp;</div></td>
      <td width="2%" height="18">&nbsp;</td>
      <td height="18" colspan="2">Current Assets:</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18"><div align="left">4</div></td>
      <td height="18">&nbsp;</td>
      <td width="2%" height="18">&nbsp;</td>
      <td width="44%" height="18">Cash on Hand and in Bank</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">5</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">Temporary Investments</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">6</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">Deposits</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">7</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">Accounts Receivable</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">8</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">Loans and Advances</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">9</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">Outstanding Retirement Loan to Faculty/Staff</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">10</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">Inventories</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">11</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10"> <hr size="1"></td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">12</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">Fixed Assets:</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">13</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">Land and Land Improvements</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">14</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">Less : Accumulated Depreciation of Land Improvements</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">15</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10"><hr size="1"></td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">16</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">Buildings &amp; Buildings Improvements</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">17</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">Less : Accumulated Depreciation</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">18</td>
      <td height="10" colspan="3">&nbsp;</td>
      <td height="10"><hr size="1"></td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">19</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;Equipments</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">20</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">Less : Accumulated Depreciation</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">21</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">&nbsp;</td>
      <td height="10"><hr size="1"></td>
      <td height="10">&nbsp;</td>
      <td height="10"> <hr size="1"></td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">22</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">&nbsp;Investments</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">23</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">24</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">Other Assets</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">25</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10"> <hr size="1"></td>
    </tr>
    <tr> 
      <td height="18">26</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18"><div align="center">SUB-TOTAL</div></td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">27</td>
      <td height="18" colspan="3">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">28</td>
      <td height="18" colspan="3">B. RESTRICTED FUND ASSETS:</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">29</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">&nbsp;Temporary Investments</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">30</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10"> <hr size="1"></td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">31</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">32</td>
      <td height="18" colspan="3">&nbsp;C. ENDOWMENT/TRUST FUND ASSETS: </td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp; </td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">33</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">Cash on Hand and in Bank</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">34</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">Temporary Investments&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp; </td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp; </td>
    </tr>
    <tr> 
      <td height="18">35</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">Investment with Philbanking Development Corporation 
        (56 shares)</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">36</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">Investment with Seafront Petroleum and Mineral 
        Resources, Inc. (175,360 shares)</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">37</td>
      <td height="10" colspan="3">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10"><hr size="1"></td>
      <td height="10">&nbsp;</td>
      <td height="10"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="18">38</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">40</td>
      <td height="18" colspan="3">TOTAL GENERAL AND TRUST FUND ASSETS</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">41</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10"><hr size="2"></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18" colspan="3">NOTE : Print this on another sheet of paper</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18" colspan="9"><div align="right">Page $page_numa</div></td>
    </tr>
    <tr> 
      <td height="18" colspan="9"><div align="center">L I A B I L I T I E S &nbsp;&nbsp;A 
          N D &nbsp;&nbsp;E Q U I T Y</div></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18" colspan="3">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="18">1</td>
      <td height="18" colspan="3"><strong>A. GENERAL FUND LIABILITIES : </strong></td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">2</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">Current Liabilities :</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18"><div align="left">3&nbsp;&nbsp;</div></td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">Accounts Payable</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18"><div align="left">4</div></td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">Retirement Loan Payable</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">5</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">Deposits Payable</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">6</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">Faculty and Staff Accounts and Students' Accounts with Credit 
        Balances </td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">7</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">Reserved for Estimated Development Cost</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">8</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">Designated Loan Funds</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">9</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">Miscellaneous Funds</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">10</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10"><div align="center"></div></td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10"><hr size="1"></td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">11</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18"><div align="center">TOTAL CURRENT LIABILITES</div></td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">12</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">13</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">Deferred Credits/Income</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">14</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">15</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">Estimated Liability for Legal Claims</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">16</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="18">17</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2"><div align="center">TOTAL GENERAL FUND LIABILITIES</div></td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">18</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="18">19</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">20</td>
      <td height="18" colspan="3"><strong>B. RESTRICTED FUND LIABILITIES : </strong></td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">21</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">Restricted Funds</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">22</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">Designated Loan Funds</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">23</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">Miscellaneous Funds</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">24</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10"><div align="center"></div></td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10"><hr size="1"></td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">25</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18"><div align="center">SUB-TOTAL</div></td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">26</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">27</td>
      <td height="18" colspan="3"><strong>C. ENDOWMENT FUND/TRUST FUND LIABILITIES 
        : </strong></td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">28</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">General Endowment Fund</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">29</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">Scholarship Endowment Fund</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">30</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">Special Endowment Fund</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">31</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">Miscellaneous Endowment Fund</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18"><div align="right">23,335,000.00</div></td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">32</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10"><hr size="1"></td>
      <td height="10">&nbsp;</td>
      <td height="10"><div align="right">10,235,000.00</div></td>
    </tr>
    <tr> 
      <td height="10">33</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10"><hr size="1"></td>
    </tr>
    <tr valign="top"> 
      <td height="18">34</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">35</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">TOTAL TRUST FUND LIABILITIES</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">36</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="18">37</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">38</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">TOTAL GENERAL AND TRUST FUND LIABILITIES</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">40</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="18">41</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">42</td>
      <td height="18" colspan="3"><strong>CPU PROPRIETY EQUITY : </strong></td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">43</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">In Land, Buildings and Equipment</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">44</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">General Fund Balance</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">45</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10"><hr size="1"></td>
      <td height="10">&nbsp;</td>
      <td height="10"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="18">46</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">47</td>
      <td height="18" colspan="3">TOTAL GENERAL/TRUST FUND LIABILITIES AND EQUITY</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr valign="top"> 
      <td height="10">48</td>
      <td height="10" colspan="3">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10"><hr size="2"></td>
    </tr>
  </table>
  </form>
</body>
</html>
<%
dbOP.cleanUP();
%>
