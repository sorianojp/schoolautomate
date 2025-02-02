<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
	TD{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:11px;
	}
	TD.topBorder{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		border-top:dashed 1px #000000;
		font-size:11px;
	}
	TD.bottomBorder{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		border-bottom:dashed 1px  #000000; 
		font-size:11px;
	}		
	
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
//remove all fee from list.


function RemoveFeeName(removeIndex)
{
	document.form_.remove_index.value = removeIndex;
	ReloadPage();
}
function ReloadPage()
{
	document.form_.print_pg.value = "";
	document.form_.show_all.value ="1";
	document.form_.submit();
}

function PrintPg() {
	document.form_.print_pg.value = "1";
	document.form_.submit();
}

function UpdatePage(){
	location = "./specific_acct_cpu.jsp?date_from=" +
				document.form_.date_from.value;
}

function UpdateCollegeName(){

	if (document.form_.c_index.selectedIndex != 0) 
		document.form_.c_name.value = 
				document.form_.c_index[document.form_.c_index.selectedIndex].text;
	else
		document.form_.c_name.value= "";
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,EnrlReport.FeeExtraction,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

if(WI.fillTextValue("print_pg").length() > 0){%>
		<jsp:forward page="./specific_acct_cpu_details_print.jsp" />
<%return;
}	
	String strErrMsg = null;
	String strTemp = null;

	int iListCount = 0;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","specific_acct.jsp");
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
//authenticate this user.
/**
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"specific_acct.jsp");
**/
//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
Vector vRetResult= null;
Vector vStudList = null;
double dTotalAmount = 0d;
enrollment.FAFeeAdjustmentCPU fAdjust = new enrollment.FAFeeAdjustmentCPU();


if (WI.fillTextValue("show_all").equals("1")){
		vRetResult = fAdjust.viewAccountWithTransOnDateDetail(dbOP,request);
		if (vRetResult == null)
			strErrMsg = fAdjust.getErrMsg();
			
		if (vRetResult != null){
			vStudList = fAdjust.viewEnrolledStudentsOnDateDetail(dbOP,request);
			if (vStudList != null) 
				strErrMsg = fAdjust.getErrMsg();
		}
}

String[] astrConvSem ={"Summer", "1st Semester", "2nd Semester", "3rd Semester", ""};

%>
<form name="form_" action="./specific_acct_cpu_details.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          SPECIFIC FEE RECEIVABLE PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\"><strong>", "</strong></font>","")%>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0"  cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td width="11%">COLLEGE</td>
      <td colspan="2">
        <select name="c_index" onChange="UpdateCollegeName()">
		<option value=""> ALL </option>
		<%=dbOP.loadCombo("c_index", "c_name", " from college where is_del = 0",
							WI.fillTextValue("c_index"),false)%>
        </select>      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>SY / TERM </td>
      <td colspan="2">
<%
	strTemp = WI.fillTextValue("sy_from");
	if (strTemp.length() == 0 && WI.fillTextValue("first_load").length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	}
%>
	  <input name="sy_from" type="text" size="4" maxlength="4" 
	  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to')"> 
        - 
<%
	strTemp = WI.fillTextValue("sy_to");
	if (strTemp.length() == 0 && WI.fillTextValue("first_load").length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	}
%>
        <input name="sy_to" type="text" class="textbox" value="<%=strTemp%>" 
			size="4" maxlength="4" readonly="true">
<%
	strTemp = WI.fillTextValue("semester");
	if (strTemp.length() == 0 && WI.fillTextValue("first_load").length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	}
%>			
        <select name="semester">
          <option value="1"> 1st </option>
		<% if (strTemp.equals("2")){%> 
          <option value="2" selected> 2nd </option>
		<%}else{%> 
          <option value="2"> 2nd </option>
		<%} if (strTemp.equals("0")){%>
          <option value="0" selected> Summer</option>
		 <%}else{%> 
          <option value="0"> Summer</option>
		 <%}%> 
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Date</td>
      <td width="19%"><% strTemp = WI.fillTextValue("date_from") ;
	 	if (strTemp.length() ==  0) 
			strTemp = WI.getTodaysDate(1);
	 %>
        <input name="date_from" type="text" size="12" maxlength="12" 
	  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;</td>
      <td width="67%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td width="3%" height="18">&nbsp;</td>
      <td colspan="3">
	  	<input type="checkbox" name="switch_details" value="checkbox" onClick="UpdatePage()">
  	  check to show summarize information </td>
    </tr>
<% if (vRetResult != null && vRetResult.size() > 0) {%> 
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp; </td>
      <td align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	  <font size="1">click to print </font></td>
    </tr>
<%}%> 
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) {%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <%strTemp = WI.fillTextValue("date_from");
  	if (strTemp.length() > 0) {
		strTemp = " on " +  WI.formatDate(strTemp,6);
	}
	
	
	if (WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0) 
		strTemp +=  " - " +
			astrConvSem[Integer.parseInt(request.getParameter("semester"))] + 
			" " +  request.getParameter("sy_from") + " - " +  request.getParameter("sy_to");
		
  %>   
  
    <tr>
      <td height="25" colspan="7"><%=WI.fillTextValue("c_name")%> <br>
      Summary of Charges of 
      Enrolment  <%=strTemp%><br>
      <br></td>
    </tr>
    <tr>
      <td class="bottomBorder"><font size="1">&nbsp;NAME OF FEES</font></td>
      <td class="bottomBorder"><div align="center"><font size="1">First Year </font></div></td>
      <td class="bottomBorder"><div align="center"><font size="1">Second Year </font></div></td>
      <td class="bottomBorder"><div align="center"><font size="1">Third Year </font></div></td>
      <td class="bottomBorder"><div align="center"><font size="1">Fourth Year</font></div></td>
      <td height="20" class="bottomBorder"><div align="center"><font size="1">Fifth Year </font></div></td>
      <td align="center" class="bottomBorder"><font size="1">TOTAL</font></td>
    </tr>
    <tr>
      <td width="27%" class="thinborder">&nbsp;</td>
      <td width="12%" class="thinborderBOTTOM">&nbsp;</td>
      <td width="12%" class="thinborderBOTTOM">&nbsp;</td>
      <td width="12%" class="thinborderBOTTOM">&nbsp;</td>
      <td width="12%" class="thinborderBOTTOM">&nbsp;</td>
      <td width="12%" height="18" class="thinborderBOTTOM">&nbsp;</td>
      <td width="13%" align="center" class="thinborder">&nbsp;</td>
    </tr>
<% 	String strHandsOn = "0";
	double dTotalRowAmount = 0d;
	boolean bolInfiniteLoop = true;
	boolean bolFormatFloat = false;
for (int i =0 ; i < vRetResult.size();) {
	bolInfiniteLoop = true;
	dTotalRowAmount = 0d;
	if(i > 0) {
		bolFormatFloat = true;
	}
%> 
    <tr>
      <td height="20" class="thinborder">&nbsp;
	  <% if (i < vRetResult.size() && vRetResult.elementAt(i) != null){%>
	   	<%=WI.getStrValue((String)vRetResult.elementAt(i),"--")%>
      <% vRetResult.setElementAt(null, i);
	   
	   }%></td>
      <td align="right" class="thinborderBOTTOM">
	  <% if (i < vRetResult.size() &&  vRetResult.elementAt(i) == null &&
	  		 ((String)vRetResult.elementAt(i+1)).equals("1")){

			bolInfiniteLoop = false;
			dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResult.elementAt(i+2),",",""),"0"));
	   %> <%=WI.getStrValue((String)vRetResult.elementAt(i+2),"--")%>
	  <% i += 3;
	  
	  }else{%> 0.00 <%}%>	  </td>
      <td align="right" class="thinborderBOTTOM">
	  <% if (i < vRetResult.size() &&  vRetResult.elementAt(i) == null && 
	  		 ((String)vRetResult.elementAt(i+1)).equals("2")){
			
			bolInfiniteLoop = false;
			dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResult.elementAt(i+2),",",""),"0"));
	   %> <%=WI.getStrValue((String)vRetResult.elementAt(i+2),"--")%>
	  <%i += 3;}else{%> 0.00<%}%>	  </td>
      <td align="right" class="thinborderBOTTOM">
	  <% if (i < vRetResult.size() && vRetResult.elementAt(i) == null &&
	  		 ((String)vRetResult.elementAt(i+1)).equals("3")){
			
			bolInfiniteLoop = false;
			dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResult.elementAt(i+2),",",""),"0"));
	   %> <%=WI.getStrValue((String)vRetResult.elementAt(i+2),"--")%>
	  <%i += 3;}else{%> 0.00 <%}%>	  </td>
      <td align="right" class="thinborderBOTTOM">
	  <% if (i < vRetResult.size() && vRetResult.elementAt(i) == null &&
	  		 ((String)vRetResult.elementAt(i+1)).equals("4")){
			
			bolInfiniteLoop = false;
			dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResult.elementAt(i+2),",",""),"0"));
	   %> <%=WI.getStrValue((String)vRetResult.elementAt(i+2),"--")%>
	  <%i += 3;}else{%> 0.00 
	  <%}%>	  </td>
      <td height="20" align="right" class="thinborderBOTTOM">
	  <% if (i < vRetResult.size() && vRetResult.elementAt(i) == null &&
	  		 ((String)vRetResult.elementAt(i+1)).equals("5")){
			
			bolInfiniteLoop = false;
			dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResult.elementAt(i+2),",",""),"0"));
	   %> <%=WI.getStrValue((String)vRetResult.elementAt(i+2),"--")%>
	  <%i += 3;}else{%> 0.00 
	  <%}%>	  </td>
      <td align="right" class="thinborder">
	  		<strong><%=CommonUtil.formatFloat(dTotalRowAmount,bolFormatFloat)%></strong>&nbsp;	  </td>
    </tr>

<%
 if (bolInfiniteLoop) {
 	System.out.println("specific_acct_cpu_details.jsp");
 	System.out.println("i : " + i);
	System.out.println("vRetResult.size() : " + vRetResult.size());
	System.out.println("vRetResult.elementAt(i) : " + vRetResult.elementAt(i));
	System.out.println("(String)vRetResult.elementAt(i+1) : " + (String)vRetResult.elementAt(i+1));
	break;
 }
}%> <tr>
      <td height="20" class="topBorder">&nbsp;</td>
      <td align="right" class="topBorder">&nbsp;</td>
      <td align="right" class="topBorder">&nbsp;</td>
      <td align="right" class="topBorder">&nbsp;</td>
      <td align="right" class="topBorder">&nbsp;</td>
      <td height="20" align="right" class="topBorder">&nbsp;</td>
      <td align="right" class="topBorder">&nbsp;</td>
    </tr>
  </table>
  
 <% 
 	
 	if (vStudList != null && vStudList.size() > 0) {%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td colspan="9">&nbsp;</td>
  </tr>
  <tr>
  <%strTemp = WI.fillTextValue("date_from");
  	if (strTemp.length() > 0) {
		strTemp = " on " +  WI.formatDate(strTemp,6);
	}
	
	
	if (WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0) 
		strTemp +=  " - " +
			astrConvSem[Integer.parseInt(request.getParameter("semester"))] + 
			" " +  request.getParameter("sy_from") + " - " +  request.getParameter("sy_to");
		
  %> 
  <td colspan="9"><%=WI.fillTextValue("c_name")%> Enrolment Report <%=strTemp%></td>
  </tr>
  <tr>
    <td colspan="9">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="9">Supporting List </td>
  </tr>
  <tr>
    <td colspan="9">&nbsp;</td>
  </tr>
  <tr>
    <td width="4%" class="bottomBorder"><div align="center"><font size="1">Srl</font></div></td>
    <td width="14%" class="bottomBorder"><font size="1">ID Number </font></td>
    <td width="23%" class="bottomBorder"><font size="1">Student Name </font></td>
    <td width="11%" class="bottomBorder"><font size="1">Course-Yr </font></td>
    <td width="10%" class="bottomBorder"><div align="center"><font size="1">Tuition &amp; NSTP </font></div></td>
    <td width="10%" class="bottomBorder"><div align="center"><font size="1">Misc Fees </font></div></td>
    <td width="10%" class="bottomBorder"><div align="center"><font size="1">Lab. Fees </font></div></td>
    <td width="10%" class="bottomBorder"><div align="center"><font size="1">Total Fee </font></div></td>
    <td width="8%" class="bottomBorder"><div align="center"><font size="1">Discount</font></div></td>
  </tr>
<% 	int iCtr = 1;
	for (int i =  0; i < vStudList.size() ; i+= 10) {%> 
  <tr>
    <td height="20" align="right"><%=iCtr++%>&nbsp;</td>
    <td><font size="1">&nbsp;<%=(String)vStudList.elementAt(i)%></font></td>
    <td><font size="1"><%=(String)vStudList.elementAt(i+1)%></font></td>
    <td><font size="1">&nbsp;<%=(String)vStudList.elementAt(i+2) + 
								WI.getStrValue((String)vStudList.elementAt(i+3),"(",")","") + 
								WI.getStrValue((String)vStudList.elementAt(i+4),"-","","")%></font></td>
    <td align="right"><font size="1"><%=WI.getStrValue((String)vStudList.elementAt(i+5),"0.00")%></font></td>
    <td align="right"><font size="1"><%=WI.getStrValue((String)vStudList.elementAt(i+6),"0.00")%></font></td>
    <td align="right"><font size="1"><%=WI.getStrValue((String)vStudList.elementAt(i+7),"0.00")%></font></td>
    <td align="right"><font size="1"><%=WI.getStrValue((String)vStudList.elementAt(i+8),"0.00")%></font></td>
    <td align="right"><font size="1"><%=WI.getStrValue((String)vStudList.elementAt(i+9),"0.00")%></font></td>
  </tr>

<%}%>   <tr>
    <td align="right" class="topBorder">&nbsp;</td>
    <td class="topBorder">&nbsp;</td>
    <td class="topBorder">&nbsp;</td>
    <td class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
  </tr>
  </table>
  
  
<%} // vStudList != null
} // 

%> 




  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>


<input type="hidden" name="show_all" value="0">
<input type="hidden" name="print_pg">
<input type="hidden" name="c_name" value="<%=WI.fillTextValue("c_name")%>">
<input type="hidden" name="first_load" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
