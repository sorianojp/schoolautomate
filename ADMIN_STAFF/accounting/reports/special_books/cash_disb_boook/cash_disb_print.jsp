<%@ page language="java" import="utility.*,Accounting.Report.ReportSpecialBooks,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
		return;
	}

//end of authenticaion code.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Reports - Special Books-Cash disbursement","cash_disb_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
		<%
		return;
	}
///insert here the cancelled vouchers if it is asked.. 
strErrMsg = null;
/** showing the cancelled vouchers at bottom.

    if(WI.fillTextValue("inc_cancelled").length() > 0 && false) {
		String strSQLQuery = null;
		
	    String strCurYr = WI.getTodaysDate().substring(0,4);
	    strCurYr = String.valueOf(Integer.parseInt(strCurYr) - 1) + "-01-01";

		dbOP.forceAutoCommitToFalse();
      	strSQLQuery = "insert into AC_JV (JV_NUMBER,JV_DATE,ENCODED_DATE,ENCODED_BY,IS_LOCKED,"+
        	"LOCK_DATE,JV_TYPE,IS_CD,PAYEE_NAME,IS_GIVEN_PAYEE,DATE_GIVEN,FUND_INDEX_,"+
	        "GL_TYPE,RESPONSIBILITY_CENTER,RESPONSIBILITY_CODE,OLD_JV_INDEX) "+
    	    "select JV_NUMBER,JV_DATE,ENCODED_DATE,ENCODED_BY,IS_LOCKED,"+
        	"LOCK_DATE,JV_TYPE,IS_CD,PAYEE_NAME,IS_GIVEN_PAYEE,DATE_GIVEN,FUND_INDEX_,"+
	        "GL_TYPE,RESPONSIBILITY_CENTER,RESPONSIBILITY_CODE,jv_index from AC_JV_CANCELLED where jv_date >='"+
    	    strCurYr+"'";
		if(dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false) == -1) {
    	    strErrMsg = "Error in getting cancelled voucher (1).";
      	}
      	else {
        	strSQLQuery = "insert into AC_CD_CHECK_DTL (CD_INDEX,CD_COA_INDEX,BANK_INDEX,"+
	          "CHECK_NO,AMOUNT,CHK_DATE,CHK_STAT,PAYEE_NAME,chk_release_date,CHECK_NO_INT) "+
    	      "select CD_INDEX,CD_COA_INDEX,BANK_INDEX,"+
        	  "CHECK_NO,AMOUNT,CHK_DATE,CHK_STAT,PAYEE_NAME,chk_release_date,CHECK_NO_INT from "+
	          " AC_CD_CHECK_DTL_CANCELLED where exists (select * from ac_jv where old_jv_index = "+
    	      "cd_index) ";
        	if(dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false) == -1) {
	          strErrMsg = "Error in getting cancelled voucher (2).";
    	      strSQLQuery = "delete from AC_JV where OLD_JV_INDEX is not null";
        	  dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
    	    }
        	else {
	          //i have to update the jv indexes.. and amount to 0.
    	      strSQLQuery = "update AC_CD_CHECK_DTL set amount=0,cd_index = jv_index from AC_CD_CHECK_DTL "+
        	    "join ac_jv on (cd_index = OLD_JV_INDEX) where OLD_JV_INDEX is not null";
	          dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
          
    	      strSQLQuery = "update AC_JV_DC  set amount=0,AC_JV_DC.jv_index = ac_jv.jv_index from AC_JV_DC  "+
        	    "join ac_jv on (AC_JV_DC.jv_index = OLD_JV_INDEX) where OLD_JV_INDEX is not null";
	          dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
    	      
        	  strSQLQuery = "update AC_JV_DC_GROUP  set AC_JV_DC_GROUP.jv_index = ac_jv.jv_index from AC_JV_DC_GROUP  "+
	            "join ac_jv on (AC_JV_DC_GROUP.jv_index = OLD_JV_INDEX) where OLD_JV_INDEX is not null";
    	      dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
        	}
      	}
    }
**/

if(strErrMsg != null) {
	dbOP.cleanUP();
%>			<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
<%
return;
}

ReportSpecialBooks RSB = new ReportSpecialBooks();
Vector vRetResult = RSB.getCDBookDetail(dbOP, request);
    Vector vCDInfo       = new Vector();//[0] JV_INDEX,[1] JV_NUMBER,[2] JV_DATE,[3] PAYEE_NAME
    Vector vCDBankInfo   = new Vector();//[0] cd_index,[1] bank_code,[2] bank_name,[3] check_no,[4] amount
    Vector vCDColumnInfo = new Vector();//[0] JV_INDEX,[1] account_name,[2] amount
    Vector vTaxInfo      = new Vector();//[0] JV_INDEX,[1] amount
	Vector vParticular   = new Vector();//[0] jv_index, [1] particular.
	
    Vector vBank         = new Vector();//[0] bank code, [1] bank name.
    Vector vColumn       = new Vector();//[0] ACCOUNT_NAME
	
	Vector vAddlCreditColumn = new Vector();//[0] account name.. it so happened some are pure credit account - because before TAX and bank code was shown, pure credit accounts were missing.. NOw i keep it here, so i can get from summary vector.. 
	
	
	Vector vSummary      = new Vector();//

if(vRetResult == null)
	strErrMsg = RSB.getErrMsg();
else {
	vSummary = RSB.getCDBookSummary(dbOP, request);
	//System.out.println("vSummary : "+vSummary);

	if(vSummary == null) {
		strErrMsg  = RSB.getErrMsg();
		vRetResult = null;
	}
	else {
		vSummary.removeElementAt(0);vSummary.removeElementAt(0);
		
		vCDInfo           = (Vector)vRetResult.remove(0);
		vCDBankInfo       = (Vector)vRetResult.remove(0);
		vCDColumnInfo     = (Vector)vRetResult.remove(0);
		vTaxInfo          = (Vector)vRetResult.remove(0);
		vColumn           = (Vector)vRetResult.remove(0);
		vAddlCreditColumn = (Vector)vRetResult.remove(0);
		vParticular       = (Vector)vRetResult.remove(0);
		vBank             = (Vector)vCDBankInfo.remove(0);
		
		//I have to make sure the columns not present in vSummary must go.. 
		int iIndexOf = 0; 
		for(int i = 0; i < vSummary.size(); i += 4) {
			strTemp = (String)vSummary.elementAt(i);
			iIndexOf = vColumn.indexOf(strTemp);
			if(iIndexOf > -1) {
				//I have to make it () if is_debit = 0
				if(vSummary.elementAt(i + 2).equals("0"))
					vSummary.setElementAt( "("+((String)vSummary.elementAt(i + 3)) + ")",i + 3);
			
				continue;
			}
			vSummary.remove(i);vSummary.remove(i);vSummary.remove(i);vSummary.remove(i);
			i = i -4;
			
			
		}
		
		//I have to arrange the vSummary :
		String strV1 = null;String strV2 = null;String strV3 = null;String strV4 = null;
		for(int i = 0 ; i < vAddlCreditColumn.size(); ++i) {
			strTemp  = (String)vAddlCreditColumn.elementAt(i);
			iIndexOf = vSummary.indexOf(strTemp);
			if(iIndexOf == -1) {
				//System.out.println(" i :"+i+" , strTemp : "+ strTemp);
				continue;
			}
				
			strV1 = (String)vSummary.remove(iIndexOf);
			strV2 = (String)vSummary.remove(iIndexOf);
			strV3 = (String)vSummary.remove(iIndexOf);
			strV4 = (String)vSummary.remove(iIndexOf);
			//System.out.print("strV1 : "+strV1);
			//System.out.print(", strV2 : "+strV2);
			//System.out.print(", strV3 : "+strV3);
			//System.out.println(", strV4 : "+strV4);
			
			vSummary.insertElementAt(strV4, 0);
			vSummary.insertElementAt(strV3, 0);
			vSummary.insertElementAt(strV2, 0);
			vSummary.insertElementAt(strV1, 0);
		}
		
	}	
}

Vector vTempInfo = new Vector();
//System.out.println(vRetResult);
//System.out.println(vCDBankInfo);
//System.out.println(vCDColumnInfo);
//System.out.println(vColumn);
int iRowIncr = 1;
int iColIncr = 1;


boolean bolRemoveCheck = false; boolean bolIsGroup = false;
if(WI.fillTextValue("remove_check").length() > 0) 
	bolRemoveCheck = true;
if(WI.fillTextValue("group_").length() > 0) 
	bolIsGroup = true;
	

//System.out.println("vCDInfo : "+vCDInfo);
//System.out.println("vCDBankInfo : "+vCDBankInfo);
//System.out.println("vCDColumnInfo : "+vCDColumnInfo);
//System.out.println("vColumn : "+vColumn);
//System.out.println("vBank : "+vBank);
//System.out.println("vAddlCreditColumn : "+vAddlCreditColumn);
//System.out.println("sundry listing : "+RSB.vSundryInfo);
	
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsAUF = strSchCode.startsWith("AUF");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
</head>
<script language="javascript" src="../../../../../jscript/formatFloat.js"></script>
<script language="javascript">
function PrintPg() {
	<%if(WI.fillTextValue("print_").equals("1")){%>
		window.print();
	<%}%>
}
/**
//very slow.. rejected..
function UpdateLabel() {
	var iRowCount = document.form_.row_count.value;
	var iColCount = document.form_.col_count.value;
	var strTemp;
	var vColTotal = 0;
	for(var i = 1; i < iColCount; ++i) {
		vColTotal = 0
		for(var p = 1; p < iRowCount; ++p) {
			strTemp = String(p).toString()+String(i).toString();//11,21,31,.... sum to 01.			
			strTemp = document.getElementById(strTemp);
			if(!strTemp) 
				continue;
			strTemp = strTemp.innerHTML;
			if(strTemp == "&nbsp;")
				continue;
			strTemp = this.removeChar(strTemp, ",")
			//alert(strTemp);
			vColTotal += eval(strTemp);
		}
		strTemp = this.formatFloat(vColTotal, 2, true);
		if(i == 1)
			alert(strTemp+" " +vColTotal);
		document.getElementById("0"+i).innerHTML = strTemp;
		
	}
	
	
}**/
function removeChar(strInput, strDelim) {
	var outPut = "";
	var iLen = strInput.length;
	var i = 0;
	while(i < iLen) {
		if(strInput.charAt(i) == strDelim) {
			++i;
			continue;
		}
		outPut += strInput.charAt(i++);
	}
	return outPut;	
}
</script>
<body onLoad="PrintPg();">
<form name="form_" method="post">
<%if(strErrMsg != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:14px; font-weight:bold; color:#FF0000"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
<%dbOP.cleanUP();return;}
int iRowPerPg = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
int iCurPg    = 0;

int iIndexOf  = 0; Vector vTempJVInfo = null; double dTemp = 0d; double dWithholdTax = 0d;
double[] dCashInBank = new double[vBank.size()/2];

String strDebitCredit = null;

if(vCDInfo != null && vCDInfo.size() > 0) {
//double dTotalDebit  = ((Double)vRetResult.remove(0)).doubleValue();
//double dTotalCredit = ((Double)vRetResult.remove(0)).doubleValue();
Integer iIntObj = null; String strTableWidth = null;
int iPageOf = 1;
int iTotalPages = vCDInfo.size()/(4 * iRowPerPg);
if(vCDInfo.size() % (4 * iRowPerPg) > 0)
	++iTotalPages;

String strPagesToPrint = WI.fillTextValue("print_page_index");
Vector vPagesToPrint = new Vector();
if(strPagesToPrint.length() > 0) 
	vPagesToPrint = CommonUtil.convertCSVToVector(strPagesToPrint, ",",true);
//System.out.println(vPagesToPrint);

strTableWidth = " width = "+ (vColumn.size() + 4 + vBank.size() ) * 66 ;

String strLHS = "";
String strRHS = null; 

int iSundryIndex = -1;

String strSundryNameDisp = null; boolean bolSundryExists = false;
String strSundryValDisp  = null;

String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
String strAddrLine1  = SchoolInformation.getAddressLine1(dbOP,false,false);

for(int i = 0; i < vCDInfo.size(); ++iPageOf){
if(vPagesToPrint.size() > 0) {
	if(vPagesToPrint.indexOf(Integer.toString(iPageOf - 1)) == -1) {
		strLHS = "<!--";strRHS = "-->";
		//for(int a = 0; a < iRowPerPg; ++a) {
		//	if(vCDInfo.size() == 0)
		//		break;
		//	vCDInfo.remove(i);vCDInfo.remove(i);vCDInfo.remove(i);vCDInfo.remove(i);
		//}
		//continue;
	}
	else {
		strLHS = "";strRHS = "";
	}
}
//System.out.println("Printing : "+iPageOf);
iCurPg = 0;%>
<%=strLHS%>
<%if(strLHS.length() == 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="100%" height="25" align="center"><font size="2">
      <strong><%=strSchoolName%></strong><br>
        <font size="1"><%=strAddrLine1%></font></font><br>
        Cash disbursement book Detail: <u><%=request.getAttribute("report_format")%></u>		
	 </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="22" align="right" style="font-size:10px">Page <%=iPageOf%> of <%=iTotalPages%>&nbsp;</td>
    </tr>
  </table>
  
  <table border="0" cellpadding="0" cellspacing="0" class="thinborder" <%=strTableWidth%>>
    <tr style="font-weight:bold">
      <td align="center" style="font-size:9px;" class="thinborder" height="22" width="60">DATE</td>
      <td align="center" style="font-size:9px;" class="thinborder" width="60"><span class="thinborder" style="font-size:9px;">PAYEE NAME</span></td>
      <td align="center" style="font-size:9px;" class="thinborder" width="100">PARTICULARS</td>
      <td style="font-size:9px;" class="thinborder" width="60"><span class="thinborder" style="font-size:9px;">CD/CV #</span></td>
      <%if(!bolIsGroup){%><td align="center" style="font-size:9px; font-weight:bold" class="thinborder" width="60">WITHHELD TAXES </td><%}%>
      <%for(int q = 0; q < vBank.size(); q += 2) {%>
	  <td align="center" style="font-size:9px;" class="thinborder" width="60">CASH IN BANK<br><%=vBank.elementAt(q)%></td>
      <%if(!bolRemoveCheck){%><td align="center" style="font-size:9px;" class="thinborder" width="60">CHECK #</td><%}%>
      <%}for(int p = 0; p < vColumn.size(); ++p){
	  		if(vSummary.elementAt(p * 4 + 2).equals("0"))
				strDebitCredit = "<br>CR";
			else	
				strDebitCredit = "<br>DR";
			if(!bolIsAUF)
				strDebitCredit = "";
				
	  	if(vColumn.elementAt(p).equals("sundry"))
			iSundryIndex = p;
			%>
	  	<%if(iSundryIndex == p){bolSundryExists = true;%>
			<td align="center" style="font-size:9px;" class="thinborder" width="60">Sundry Account</td>
			<td align="center" style="font-size:9px;" class="thinborder" width="60">Sundry Amount</td>
		<%}else{%>
			<td align="center" style="font-size:9px;" class="thinborder" width="60">
				(<%=vSummary.elementAt(p*4 + 1)%>)<br><%=vColumn.elementAt(p)%><%=strDebitCredit%>			</td>
		<%}//non sundry account.. %>
		
	  <%}%>
    </tr>
<%}//show header only if strLHS > 0

for(; i < vCDInfo.size();){
iIntObj = (Integer)vCDInfo.remove(0);
/**
    Vector vCDInfo       = new Vector();//[0] JV_INDEX,[1] JV_NUMBER,[2] JV_DATE,[3] PAYEE_NAME
    Vector vCDBankInfo   = new Vector();//[0] cd_index,[1] bank_code,[2] bank_name,[3] check_no,[4] amount
    Vector vCDColumnInfo = new Vector();//[0] JV_INDEX,[1] account_name,[2] amount
    Vector vTaxInfo      = new Vector();//[0] JV_INDEX,[1] amount
    
    Vector vColumn       = new Vector();//[0] ACCOUNT_NAME
**/
%>
    <tr align="right">
      <td align="center" style="font-size:9px;" class="thinborder" height="22"><%=vCDInfo.remove(1)%></td>
      <td align="center" style="font-size:9px;" class="thinborder"><%=vCDInfo.remove(1)%></td>
      <td align="center" style="font-size:9px;" class="thinborder">
	  <%
	  iIndexOf = vParticular.indexOf(iIntObj);
	  if(iIndexOf == -1)
	  	strTemp = "&nbsp;";
	  else
	  	strTemp = (String)vParticular.remove(iIndexOf + 1);
		
	  %>
	  <%=strTemp%></td>
      <td align="left" style="font-size:9px;" class="thinborder"><%=vCDInfo.remove(0)%></td>
      <%if(!bolIsGroup){%><td style="font-size:9px;" class="thinborder">
	  <%
	  strTemp = null;
	  iIndexOf = vTaxInfo.indexOf(iIntObj);
	  if(iIndexOf != -1) {
		strTemp = (String)vTaxInfo.elementAt(iIndexOf + 1);
		dWithholdTax += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp, "0"), ",",""));
		vTaxInfo.removeElementAt(iIndexOf);vTaxInfo.removeElementAt(iIndexOf);
	  }if(strTemp == null)
	  	strTemp = "0.00";%>
	  <label id="<%=iRowIncr%><%=iColIncr++%>"><%=strTemp%></label>	  
	  </td><%}//d onot show this if group by is called.%>
      <%iIndexOf = 0;vTempInfo = new Vector();
	  while( (iIndexOf = vCDBankInfo.indexOf(iIntObj,iIndexOf)) != -1) {
	  	vCDBankInfo.removeElementAt(iIndexOf);//jv index is not needed anymore.
		vTempInfo.addElement(vCDBankInfo.remove(iIndexOf)); vTempInfo.addElement(vCDBankInfo.remove(iIndexOf));
		vTempInfo.addElement(vCDBankInfo.remove(iIndexOf));
	  }
	  for(int q = 0; q < vBank.size(); q += 2) {
	  iIndexOf = vTempInfo.indexOf(vBank.elementAt(q));
	  if(iIndexOf == -1) {
	  	strErrMsg = "&nbsp;";strTemp = "&nbsp;";
	  }
	  else {
	  	strTemp = (String)vTempInfo.remove(iIndexOf + 1);//check no.
		dCashInBank[q/2] += ((Double)vTempInfo.elementAt(iIndexOf + 1)).doubleValue();
		
		strErrMsg = CommonUtil.formatFloat(((Double)vTempInfo.remove(iIndexOf + 1)).doubleValue(), true);
		
		vTempInfo.removeElementAt(iIndexOf);
	  }%>
	  	<td style="font-size:9px;" class="thinborder" width="60"><%if(false){%><label id="<%=iRowIncr%><%=iColIncr++%>"><%=strErrMsg%></label><%}%><%=strErrMsg%></td>
      	<%if(!bolRemoveCheck){%><td align="center" style="font-size:9px;" class="thinborder" width="60"><%=RSB.groupCheckNumber(strTemp)%></td><%}%>
      <%}iIndexOf = 0;vTempInfo = new Vector();
	  while( (iIndexOf = vCDColumnInfo.indexOf(iIntObj,iIndexOf)) != -1) {
	  	vCDColumnInfo.removeElementAt(iIndexOf);//jv index is not needed anymore.
		vTempInfo.addElement(vCDColumnInfo.remove(iIndexOf)); vTempInfo.addElement(vCDColumnInfo.remove(iIndexOf));
	  }
	  
	  for(int p = 0; p < vColumn.size(); ++p){
	  	if( (iIndexOf = vTempInfo.indexOf(vColumn.elementAt(p))) != -1) {
			strErrMsg = (String)vTempInfo.remove(iIndexOf + 1);vTempInfo.removeElementAt(iIndexOf);
		}
		else	
			strErrMsg = "&nbsp;";
		strTemp = null;;
		
		//Here i have to check if this is for sundry.. 
		if(iSundryIndex == p) {
			String strSundryName = null;strSundryNameDisp = "";
			String strSundryAmt  = null;strSundryValDisp = "";
			//strTemp = "<table width=60 cellpadding=0 cellspacing=0 class='thinborder'>";
			strTemp = "";
			while(true) {
				iIndexOf = RSB.vSundryInfo.indexOf(iIntObj);
				if(iIndexOf == -1)
					break;
				//I have to list all sundry accounts here.
				strSundryName = (String)RSB.vSundryInfo.remove(iIndexOf + 1);
				strSundryAmt = (String)RSB.vSundryInfo.remove(iIndexOf + 1);
				RSB.vSundryInfo.remove(iIndexOf);RSB.vSundryInfo.remove(iIndexOf);
				if(strSundryNameDisp.length() > 0) {
					strSundryNameDisp += "<br>";
					strSundryValDisp  += "<br>";
				}
				strSundryNameDisp += strSundryName;
				if(strSundryAmt.startsWith("-"))
					strSundryValDisp += "("+strSundryAmt.substring(1)+")";
				else
					strSundryValDisp += strSundryAmt;
				//if(strTemp.length() > 0) 
				//	strTemp = "<br>"+strSundryName + "("+strSundryAmt+")";
				//else
				//	strTemp = "<br>"+strSundryName + ":"+strSundryAmt;
				//strTemp += "<tr>"+
				//		"<td class='thinborder'>"+strSundryName+"</td>"+
				//		"<td class='thinborder'>"+strSundryAmt+"</td>"+
				//		"</tr>";
					
				if(RSB.vSundryInfo.size() == 0) 
					break;
			}//end of while true.
			if(strTemp.length() > 0) 
				strTemp = "<div align=left>"+strTemp+"</div>";
			//if(!strTemp.endsWith("</tr>"))//empty.. 
			//	strTemp = "&nbsp;";
			//else
			//	strTemp += "</table>";
			
		}//end of if sundryindex == p
		if(iSundryIndex != p)
			strTemp = strErrMsg;
		
	  	if(strLHS.length() == 0 && iSundryIndex != p){%>
	  	<td style="font-size:9px;" class="thinborder" width="60"><%//=strErrMsg%><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
	  <%}//added condition to reduce the page size.. 
	  }++iRowIncr;iColIncr = 1;
	  if(bolSundryExists){%>
	  <td style="font-size:9px;" class="thinborder" width="60"><%//=strErrMsg%><%=WI.getStrValue(strSundryNameDisp, "&nbsp;")%></td>
	  <td style="font-size:9px;" class="thinborder" width="60"><%//=strErrMsg%><%=WI.getStrValue(strSundryValDisp, "&nbsp;")%></td>
	  <%}%>
    </tr>
<%if(i == vCDInfo.size() && strLHS.length() == 0){%>
    <tr align="right">
      <td height="26" colspan="4" class="thinborder"><strong>TOTAL :&nbsp;&nbsp;&nbsp; </strong></td>
      <%if(!bolIsGroup){%><td class="thinborder" style="font-size:9px;"><%=CommonUtil.formatFloat(dWithholdTax,true)%></td><%}%>
      <%for(int q = 0; q < vBank.size(); q += 2) {%>
	  <td style="font-size:9px;" class="thinborder" width="60"><%=CommonUtil.formatFloat(dCashInBank[q/2],true)%></td>
      <%if(!bolRemoveCheck){%><td align="center" style="font-size:9px;" class="thinborder" width="60">&nbsp;</td><%}%>
      <%}
	  strTemp = "";
	  for(int p = 0; p < vColumn.size(); ++p){
	  if(bolSundryExists && p == vColumn.size() - 1)
	  	strTemp = " colspan=2";%>
	  	<td style="font-size:9px;" class="thinborder" width="60"<%=strTemp%>>
			<%if(vColumn.elementAt(p).equals(vSummary.elementAt(0))){//System.out.println("Printing: "+vSummary.elementAt(3));%>
				<%=vSummary.elementAt(3)%>
			<%vSummary.removeElementAt(0);vSummary.removeElementAt(0);vSummary.removeElementAt(0);vSummary.removeElementAt(0);
			}else{%>&nbsp;<%}%>		</td>
	  <%}%>
    </tr>
<%}//print at end.. 
if(++iCurPg == iRowPerPg)
	break;
}%>
  </table>

<%if(i < vCDInfo.size()){%>
<DIV style="page-break-after:always" >&nbsp;</DIV>
<%}%>

<%=WI.getStrValue(strRHS)%>

<%}//end of vRetResult.. 
}//end of big loop - if condition.
%>

<%if(WI.fillTextValue("inc_cancelled").length() > 0 && false) {
	if(RSB.vCancelledVoucher == null || RSB.vCancelledVoucher.size() == 0) {%>
		<font style="font-size:12px; font-weight:bold;">No Cancelled Voucher Found for specified period.</font>
	<%}else{
int iMaxRows = RSB.vCancelledVoucher.size()/8;
int iDefRows = iMaxRows;	
	%><br>
	<font style="font-weight:bold; font-size:14px;"><u>List of Cancelled Vouchers</u></font>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
		<td width="24%">
			<table width="100%"  border="0" cellpadding="0" cellspacing="0" class="thinborder">
				<tr>
					<td width="50%" style="font-size:9px;font-weight:bold" class="thinborder">Voucher Number</td>
					<td width="50%" style="font-size:9px;font-weight:bold" class="thinborder">Voucher Date</td>
				</tr>
				<%while(iMaxRows > 0) {
					--iMaxRows;
					if(RSB.vCancelledVoucher.size() == 0)
						break;
				%>	
				<tr>
					<td width="50%" style="font-size:9px;" class="thinborder"><%=RSB.vCancelledVoucher.remove(0)%></td>
					<td width="50%" style="font-size:9px;" class="thinborder"><%=RSB.vCancelledVoucher.remove(0)%></td>
				</tr>
				<%}%>
				
			</table>
		</td>
		<td width="1%"></td>
		<td width="24%">
		<%if(RSB.vCancelledVoucher.size() > 0) {
			iMaxRows = iDefRows;
		%>
			<table width="100%"  border="0" cellpadding="0" cellspacing="0" class="thinborder">
				<tr>
					<td width="50%" style="font-size:9px;font-weight:bold" class="thinborder">Voucher Number</td>
					<td width="50%" style="font-size:9px;font-weight:bold" class="thinborder">Voucher Date</td>
				</tr>
				<%while(iMaxRows > 0) {
					--iMaxRows;
					if(RSB.vCancelledVoucher.size() == 0)
						break;
				%>	
				<tr>
					<td width="50%" style="font-size:9px;" class="thinborder"><%=RSB.vCancelledVoucher.remove(0)%></td>
					<td width="50%" style="font-size:9px;" class="thinborder"><%=RSB.vCancelledVoucher.remove(0)%></td>
				</tr>
				<%}%>
				
			</table>
		<%}%>
		</td>
		<td width="1%"></td>
		<td width="24%">
		<%if(RSB.vCancelledVoucher.size() > 0) {
			iMaxRows = iDefRows;
		%>
			<table width="100%"  border="0" cellpadding="0" cellspacing="0" class="thinborder">
				<tr>
					<td width="50%" style="font-size:9px;font-weight:bold" class="thinborder">Voucher Number</td>
					<td width="50%" style="font-size:9px;font-weight:bold" class="thinborder">Voucher Date</td>
				</tr>
				<%while(iMaxRows > 0) {
					--iMaxRows;
					if(RSB.vCancelledVoucher.size() == 0)
						break;
				%>	
				<tr>
					<td width="50%" style="font-size:9px;" class="thinborder"><%=RSB.vCancelledVoucher.remove(0)%></td>
					<td width="50%" style="font-size:9px;" class="thinborder"><%=RSB.vCancelledVoucher.remove(0)%></td>
				</tr>
				<%}%>
				
			</table>
		<%}%>
		</td>
		<td width="1%"></td>
		<td width="24%">
		<%if(RSB.vCancelledVoucher.size() > 0) {
			iMaxRows = iDefRows;
		%>
			<table width="100%"  border="0" cellpadding="0" cellspacing="0" class="thinborder">
				<tr>
					<td width="50%" style="font-size:9px;font-weight:bold" class="thinborder">Voucher Number</td>
					<td width="50%" style="font-size:9px;font-weight:bold" class="thinborder">Voucher Date</td>
				</tr>
				<%while(iMaxRows > 0) {
					--iMaxRows;
					if(RSB.vCancelledVoucher.size() == 0)
						break;
				%>	
				<tr>
					<td width="50%" style="font-size:9px;" class="thinborder"><%=RSB.vCancelledVoucher.remove(0)%></td>
					<td width="50%" style="font-size:9px;" class="thinborder"><%=RSB.vCancelledVoucher.remove(0)%></td>
				</tr>
				<%}%>
				
			</table>
		<%}%>
		</td>
	</tr>
  </table>
		

<!--
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" style="font-size:9px;font-weight:bold" class="thinborderTOPLEFTBOTTOM">Voucher Number</td>
      <td style="font-size:9px;font-weight:bold" class="thinborderALL">Voucher Date</td>
      <td style="font-size:9px;font-weight:bold">&nbsp;</td>
      <td style="font-size:9px;font-weight:bold" class="thinborderTOPLEFTBOTTOM">Voucher Number</td>
      <td style="font-size:9px;font-weight:bold" class="thinborderALL">Voucher Date</td>
      <td style="font-size:9px;font-weight:bold">&nbsp;</td>
      <td style="font-size:9px;font-weight:bold" class="thinborderTOPLEFTBOTTOM">Voucher Number</td>
      <td style="font-size:9px;font-weight:bold" class="thinborderALL">Voucher Date</td>
    </tr>
<%while( RSB.vCancelledVoucher.size() > 0) {%>
   <tr>
      <td height="25" style="font-size:9px;" class="thinborderBOTTOMLEFT">&nbsp;<%=RSB.vCancelledVoucher.remove(0)%></td>
      <td style="font-size:9px;" class="thinborderBOTTOMLEFTRIGHT">&nbsp;<%=RSB.vCancelledVoucher.remove(0)%></td>
      <td style="font-size:9px;">&nbsp;</td>
      <td style="font-size:9px;" class="thinborderBOTTOMLEFT">&nbsp;
	  <%if(RSB.vCancelledVoucher.size() > 0) {%>
	  	<%=RSB.vCancelledVoucher.remove(0)%>
	  <%}else{%>
	  	xx
	  <%}%> 
	  </td>
      <td style="font-size:9px;" class="thinborderBOTTOMLEFTRIGHT">
	  <%if(RSB.vCancelledVoucher.size() > 0) {%>
	  	<%=RSB.vCancelledVoucher.remove(0)%>
	  <%}else{%>
	  	xx
	  <%}%> 
	  </td>
      <td style="font-size:9px;">&nbsp;</td>
      <td style="font-size:9px;" class="thinborderBOTTOMLEFT">
	  <%if(RSB.vCancelledVoucher.size() > 0) {%>
	  	<%=RSB.vCancelledVoucher.remove(0)%>
	  <%}else{%>
	  	xx
	  <%}%> 
	  </td>
      <td style="font-size:9px;" class="thinborderBOTTOMLEFTRIGHT">
	  <%if(RSB.vCancelledVoucher.size() > 0) {%>
	  	<%=RSB.vCancelledVoucher.remove(0)%>
	  <%}else{%>
	  	xx
	  <%}%> 
	  </td>
    </tr>
<%}%>
</table>
<%}%>

-->
<%}%> 



<%if(false){%>
  <table width="1600" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="26" align="center" class="thinborder"><font size="1"><strong>DATE</strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>PAYEE NAME </strong></font></td>
      <td class="thinborder" align="center"><font size="1"><strong>WITHHELD TAXES </strong></font></td>
      <td class="thinborder" align="center"><font size="1"><strong>CASH IN BANK<br>
        $BANK_NAME </strong></font></td>
      <td class="thinborder" align="center"><font size="1">CD/CV # </font></td>
      <td class="thinborder" align="center"><font size="1">CHECK # </font></td>
      <td class="thinborder" align="center"><font size="1">SSS Premiums </font></td>
      <td class="thinborder" align="center"><font size="1">PHIC</font></td>
      <td class="thinborder" align="center"><font size="1">Pag-Ibig Premiums </font></td>
      <td class="thinborder" align="center"><font size="1">PERAA Premiums </font></td>
      <td class="thinborder" align="center"><font size="1">SSS Loan Payable </font></td>
      <td class="thinborder" align="center"><font size="1">PERAA Loan Payable </font></td>
      <td class="thinborder" align="center"><font size="1">Salaries &amp; Wages </font></td>
      <td class="thinborder" align="center"><font size="1">Honorarium</font></td>
      <td class="thinborder" align="center"><font size="1">Periodicals&amp; Magazines </font></td>
      <td class="thinborder" align="center"><font size="1">School Uniform </font></td>
    </tr>
    <tr>
      <td width="4%" height="26" class="thinborder">01-Aug-07 </td>
      <td width="6%" class="thinborder">&nbsp;</td>
      <td width="5%" class="thinborder" align="right">credit</td>
      <td width="6%" class="thinborder" align="right">credit</td>
      <td width="3%" class="thinborder" align="right">&nbsp;</td>
      <td width="4%" class="thinborder" align="right">&nbsp;</td>
      <td width="4%" class="thinborder" align="right">debit</td>
      <td width="3%" class="thinborder" align="right">&nbsp;</td>
      <td width="4%" class="thinborder" align="right">&nbsp;</td>
      <td width="8%" class="thinborder" align="right">&nbsp;</td>
      <td width="7%" class="thinborder" align="right">&nbsp;</td>
      <td width="5%" class="thinborder" align="right">&nbsp;</td>
      <td width="5%" class="thinborder" align="right">&nbsp;</td>
      <td width="9%" class="thinborder" align="right">&nbsp;</td>
      <td width="10%" class="thinborder" align="right">&nbsp;</td>
      <td width="17%" class="thinborder" align="right">&nbsp;</td>
    </tr>
</table>
<%}%>

<input type="hidden" name="row_count" value="<%=iRowIncr%>">
<input type="hidden" name="col_count" value="<%=iColIncr%>">
</form>
</body>
</html>
<%
dbOP.rollbackOP();
dbOP.cleanUP();
%>