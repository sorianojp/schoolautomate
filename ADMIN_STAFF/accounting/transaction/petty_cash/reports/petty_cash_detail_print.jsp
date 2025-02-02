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
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

int iIndexOf = 0; 

ReportSpecialBooks RSB = new ReportSpecialBooks();
	Vector vRetResult    = RSB.getPettyCashDetail(dbOP, request);
    Vector vCDInfo       = new Vector();//[0] JV_INDEX,[1] JV_NUMBER,[2] JV_DATE,[3] PAYEE_NAME, [4] voucher amt, [5] explanation.
    Vector vCDColumnInfo = new Vector();//[0] JV_INDEX,[1] account_name,[2] amount
    Vector vColumn       = new Vector();//[0] ACCOUNT_NAME

	Vector vSummary      = new Vector();//
	
	Vector vAddlCreditColumn = new Vector();//not used.. 

if(vRetResult == null)
	strErrMsg = RSB.getErrMsg();
else {
	vSummary      = RSB.getPettyCashSummary(dbOP, request);
	//System.out.println("vRetResult : "+vRetResult);
	//System.out.println("vSummary : "+vSummary);
	//System.out.println("RSB.vSundryInfo : "+RSB.vSundryInfo);

	if(vSummary == null) {
		strErrMsg  = RSB.getErrMsg();
		vRetResult = null;
	}
	else {
		vSummary.removeElementAt(0);vSummary.removeElementAt(0);
		
		vCDInfo           = (Vector)vRetResult.remove(0);
		vCDColumnInfo     = (Vector)vRetResult.remove(0);
		vColumn           = (Vector)vRetResult.remove(0);
		
		//I have to make sure the columns not present in vSummary must go.. 
		for(int i = 0; i < vSummary.size(); i += 4) {
			strTemp = (String)vSummary.elementAt(i);
			iIndexOf = vColumn.indexOf(strTemp);
			if(iIndexOf > -1)
				continue;
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
			
			vSummary.insertElementAt("("+strV4+")", 0);
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


boolean bolIsGroup = false;
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
String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
String strAddrLine1  = SchoolInformation.getAddressLine1(dbOP,false,false);

int iSundryIndex = -1;
String strSundryNameDisp = null; boolean bolSundryExists = false;
String strSundryValDisp  = null;

Integer iIntObj = null; String strTempAmount = null;

int iRowPerPg = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
int iCurRow   = 1; int iCurPage = 1;
int iTotalPage = vCDInfo.size()/(iRowPerPg * 6);
if(vCDInfo.size() % (iRowPerPg * 6) > 0) 
	++iTotalPage;
	
String strDateToPrint = null;
String strCurDate = null;

Vector vColumnTotal = new Vector(); int iIncr = 0;

for(int i = 0; i < vCDInfo.size();) {
	strDateToPrint = null;
	strCurDate = null;
	if(iCurRow > iRowPerPg ) {
		iCurRow = 1;
		++iCurPage;%>
		<DIV style="page-break-after:always" >&nbsp;</DIV>
	<%}%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="100%" height="25" align="center"><font size="2">
      <strong><%=strSchoolName%></strong><br>
        <font size="1"><%=strAddrLine1%></font></font><br>
        Petty Cash Fund Detail: <u><%=request.getAttribute("report_format")%></u>		
	 </td>
    </tr>
    <tr>
      <td width="100%" align="right" style="font-size:9px;">Page <%=iCurPage%> of <%=iTotalPage%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr style="font-weight:bold">
		<td class="thinborder" width="8%" style="font-size:9px;">DATE</td>
		<td class="thinborder" width="12%" style="font-size:9px;">PAYEE NAME </td>
		<td class="thinborder" width="4%" style="font-size:9px;">DEPT.</td>
		<td class="thinborder" width="7%" style="font-size:9px;">PCV#</td>
		<td class="thinborder" width="15%" style="font-size:9px;">EXPLANATION</td>
		<td class="thinborder" width="5%" style="font-size:9px;">TOTAL</td>
		<%for(int p = 0; p < vColumn.size(); ++p) {
		if(vColumn.elementAt(p).equals("sundry"))
			iSundryIndex = p;
	  	if(iSundryIndex == p){bolSundryExists = true;%>
			<td align="center" style="font-size:9px;" class="thinborder" width="60">Sundry Account</td>
			<td align="center" style="font-size:9px;" class="thinborder" width="60">Sundry Amount</td>
		<%}else{%>
			<td class="thinborder" style="font-size:9px;"><%=vColumn.elementAt(p)%></td>
		<%}
		}%>
	</tr>
<%for(; i < vCDInfo.size(); i += 6, ++iCurRow) {
if(iCurRow > iRowPerPg )
	break;
if(!WI.getStrValue(strCurDate).equals(vCDInfo.elementAt(i + 2))){
	strCurDate = (String)vCDInfo.elementAt(i + 2);
	strDateToPrint = strCurDate;
}
else
	strDateToPrint = strCurDate;
iIntObj = (Integer)vCDInfo.elementAt(i);

iIncr = 1;
//get total of this column.
if(vColumnTotal.size() > (iIncr - 1)) 	
	vColumnTotal.setElementAt(new Double(((Double)vCDInfo.elementAt(i + 4)).doubleValue() + ((Double)vColumnTotal.elementAt((iIncr - 1))).doubleValue()), (iIncr - 1));
else
	vColumnTotal.addElement(vCDInfo.elementAt(i + 4));
%>
	<tr>
		<td class="thinborder"><%=WI.getStrValue(strDateToPrint)%></td>
		<td class="thinborder"><%=vCDInfo.elementAt(i + 3)%></td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder"><%=vCDInfo.elementAt(i + 1)%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vCDInfo.elementAt(i + 5), "&nbsp;")%></td>
		<td class="thinborder"><%=CommonUtil.formatFloat(((Double)vCDInfo.elementAt(i + 4)).doubleValue(), true)%></td>
		<%for(int p = 0; p < vColumn.size(); ++p) {
		strTemp = (String)vColumn.elementAt(p);
		strTempAmount = null;
		++iIncr;
		System.out.println(vColumn.elementAt(p));
		System.out.println(iIncr);
		
		if(vColumnTotal.size() < iIncr)
			vColumnTotal.addElement(new Double("0"));
			
		
		iIndexOf = vCDColumnInfo.indexOf(iIntObj);
		while(iIndexOf > -1) {
			if(vCDColumnInfo.elementAt(iIndexOf + 1).equals(strTemp)) {
				strTempAmount = (String)vCDColumnInfo.elementAt(iIndexOf + 2);
				vCDColumnInfo.remove(iIndexOf);vCDColumnInfo.remove(iIndexOf);vCDColumnInfo.remove(iIndexOf);
				
				
				//get total of this column.
				if(vColumnTotal.size() > (iIncr - 1)) 	
					vColumnTotal.setElementAt(new Double(Double.parseDouble(ConversionTable.replaceString(strTempAmount, ",","")) + ((Double)vColumnTotal.elementAt((iIncr - 1))).doubleValue()), (iIncr - 1));
				else
					vColumnTotal.addElement(new Double(ConversionTable.replaceString(strTempAmount, ",","")));
				
				break;
			}
			iIndexOf += 2;
			iIndexOf = vCDColumnInfo.indexOf(iIntObj, iIndexOf);
		}
		if(iSundryIndex == p) {
			String strSundryName = null;strSundryNameDisp = "";
			String strSundryAmt  = null;strSundryValDisp = "";
			++iIncr;
			//strTemp = "<table width=60 cellpadding=0 cellspacing=0 class='thinborder'>";
			strTemp = "";
			while(true) {
				iIndexOf = RSB.vSundryInfo.indexOf(iIntObj);
				if(iIndexOf == -1)
					break;
				//I have to list all sundry accounts here.
				strSundryName = (String)RSB.vSundryInfo.remove(iIndexOf + 1);
				strSundryAmt = (String)RSB.vSundryInfo.remove(iIndexOf + 1);
				
				//get total of this column.
				if(vColumnTotal.size() > (iIncr - 1)) 	
					vColumnTotal.setElementAt(new Double(Double.parseDouble(ConversionTable.replaceString(strSundryAmt, ",","")) + ((Double)vColumnTotal.elementAt((iIncr - 1))).doubleValue()), (iIncr - 1));
				else
					vColumnTotal.addElement(new Double(ConversionTable.replaceString(strSundryAmt, ",","")));

				
				
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
		}//end of if sundryindex == p
		if(iSundryIndex != p){%>
			<td class="thinborder"><%=WI.getStrValue(strTempAmount, "&nbsp;")%></td>
		<%}
		}
	  if(bolSundryExists){%>
	  <td style="font-size:9px;" class="thinborder" width="60"><%//=strErrMsg%><%=WI.getStrValue(strSundryNameDisp, "&nbsp;")%></td>
	  <td style="font-size:9px;" class="thinborder" width="60"><%//=strErrMsg%><%=WI.getStrValue(strSundryValDisp, "&nbsp;")%></td>
	  <%}%>
	</tr>
<%}
System.out.println(vColumnTotal);%>	
	<tr style="font-weight:bold" height="20">
	  <td class="thinborder">&nbsp;</td>
	  <td class="thinborder">TOTAL</td>
	  <td class="thinborder">&nbsp;</td>
	  <td class="thinborder">&nbsp;</td>
	  <td class="thinborder">&nbsp;</td>
	  <td class="thinborder"><%=CommonUtil.formatFloat(((Double)vColumnTotal.remove(0)).doubleValue(), true)%></td>
<%if(bolSundryExists) {%>
	  <td class="thinborder">&nbsp;</td>
	  <td class="thinborder"><%=CommonUtil.formatFloat(((Double)vColumnTotal.remove(0)).doubleValue(), true)%></td>
<%}
	for(int p = 0; p < vColumn.size(); ++p) {%>
	  	<td class="thinborder"><%=CommonUtil.formatFloat(((Double)vColumnTotal.remove(0)).doubleValue(), true)%></td>
	<%}%>
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