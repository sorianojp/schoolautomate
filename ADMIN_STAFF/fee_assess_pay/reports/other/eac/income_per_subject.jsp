<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Daily cash collection page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript">
function printPg() {
	document.bgColor = "#FFFFFF";
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);

   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
  
   	document.getElementById('myADTable3').deleteRow(0);
  
   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function ReloadPage() {

}
function DeleteProj() {
	document.form_.delete_proj.value='1';
	document.form_.submit();
}
</script>
<body>
<%@ page language="java" import="utility.*,EnrlReport.FeeExtraction,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","income_per_subject.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"income_per_subject.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

String strSchCode = (String)request.getSession(false).getAttribute("school_code");

//get different grant here.
FeeExtraction feeEx = new FeeExtraction();

Vector vRetResult = null;


if(WI.fillTextValue("show_list").length() > 0) {
	vRetResult = feeEx.getPerSubjectIncomeDetailed(dbOP, request);
	if(vRetResult == null)
		strErrMsg = feeEx.getErrMsg();
}

%>

<form name="form_" method="post" action="./income_per_subject.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr>
      <td height="25" colspan="2" align="center" class="thinborderBOTTOM" valign="bottom"><strong>:::: 
          INCOME REPORT - PER SUBJECT - DETAILED::::</strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%">&nbsp;</td>
	  <td><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    
    <tr> 
      <td width="6%" height="25">&nbsp;</td>
      <td width="14%" height="25">SY/Term</td>
      <td width="80%" height="25" colspan="2"> 
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
          <option value="">ALL</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
      </select>        </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td colspan="2">
	  <select name="college">
<%
strTemp = " from college where is_del = 0 order by c_code asc";
%>
          <%=dbOP.loadCombo("c_index","c_name",strTemp, request.getParameter("college"), false)%> 
        </select>	  </td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">
		<input type="submit" name="1" value="&nbsp;&nbsp;Show Result&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_list.value='1'">	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr> 
      <td height="25" align="right" style="font-size:9px;">
	  <select name="rows_per_page">
<%
int iDefVal = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_page"), "30"));
	for(int i = 25;	i < 50; ++i) {
		if(iDefVal == i)
			strTemp = " selected";
		else
			strTemp = "";
	%><option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>  
	  </select>
	  Rows Per Page
	  
	  <a href="javascript:printPg();"><img src="../../../../../images/print.gif" border="0"></a>Print Page</td>
    </tr>
</table>

<!------------------- display report here ------------------------->
<%if(vRetResult != null) {
String strCollegeName = "select c_name from college where c_index = "+WI.fillTextValue("college");
strCollegeName = dbOP.getResultOfAQuery(strCollegeName, 0);

String[] astrConvertTerm = {"Summer","1st Semester","2nd Semester","3rd Semester"};

int iRowPrinted = 0;
String strStudIndex = "";
String strStudIDToShow = null;

double dTemp = 0d;
double dRowTotalSubFee = 0d;

double dTotalSub      = 0d;
double dTotalTutorial = 0d;
double dTotalHandsOn  = 0d;
double dTotalLab      = 0d;
double dTotalSubFee   = 0d;

String strPrintDateTime = WI.getTodaysDateTime();

for(int i = 0; i < vRetResult.size();){
	iRowPrinted = 0;
	if(i > 0) {%>
		<DIV style="page-break-before:always">&nbsp;</Div>
	<%}
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="2"><div align="center"> <font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font></div></td>
    </tr>
    <tr>
      <td colspan="2"><div align="center"></div></td>
    </tr>
    <tr>
      <td height="20" colspan="2" valign="top"><div align="center"><strong>INCOME REPORT - PER SUBJECT - DETAILED <br>
		  <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>&nbsp;&nbsp; SY :
		  <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>
          </strong></div></td>
    </tr>
    <tr valign="bottom">
      <td width="57%" height="24"><%=strCollegeName%></td>
      <td width="43%" height="24" align="right">Date and time printed : &nbsp;<%=strPrintDateTime%> &nbsp;&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    
    <tr align="center" style="font-weight:bold">
      <td width="12%" height="24" style="font-size:9px;" align="left" class="thinborderNONE">Subject Code </td>
      <td width="30%" style="font-size:9px;" align="left" class="thinborderNONE">Subject Name </td>
      <td width="4%" style="font-size:9px;" align="left" class="thinborderNONE">Units</td>
      <td width="7%" style="font-size:9px;" align="right" class="thinborderNONE">Rate/Unit</td>
      <td width="7%" style="font-size:9px;" align="right" class="thinborderNONE">Total</td>
      <td width="7%" style="font-size:9px;" class="thinborderNONE" align="right">Tutorial</td>
      <td width="7%" style="font-size:9px;" class="thinborderNONE" align="right">Hands on </td>
      <td width="7%" style="font-size:9px;" class="thinborderNONE" align="right">Lab Fee  </td>
      <td width="10%" style="font-size:9px;" class="thinborderNONE" align="right">Total Subject Fee </td>
    </tr>
	<%
	for(; i < vRetResult.size(); i += 14){
	if(++iRowPrinted > iDefVal)
		break;
	if(!strStudIndex.equals(vRetResult.elementAt(i))) {
		strStudIndex = (String)vRetResult.elementAt(i);
		strStudIDToShow = (String)vRetResult.elementAt(i + 1);
	}
	else	
		strStudIDToShow = null;
		
	if(strStudIDToShow != null) {++iRowPrinted;%>
		<tr align="right">
		  <td height="24" colspan="5" align="left" class="thinborderNONE"><%=strStudIDToShow%> <%=vRetResult.elementAt(i + 2)%></td>
		  <td class="thinborderNONE">&nbsp;</td>
		  <td class="thinborderNONE">&nbsp;</td>
		  <td class="thinborderNONE">&nbsp;</td>
		  <td class="thinborderNONE">&nbsp;</td>
		</tr>
	<%}
	dRowTotalSubFee = Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 9), ",","")) + 
					   Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 11), ",","")) +
					   Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 12), ",","")) +
					   Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 13), ",",""));

	dTotalSub      += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 9), ",",""));
	dTotalTutorial += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 11), ",",""));
	dTotalHandsOn  += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 12), ",",""));
	dTotalLab      += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 13), ",",""));

	dTotalSubFee   += dRowTotalSubFee;
	%>
    <tr align="right">
      <td height="24" align="left" class="thinborderNONE"><%=vRetResult.elementAt(i + 3)%></td>
      <td align="left" class="thinborderNONE"><%=vRetResult.elementAt(i + 4)%></td>
      <td align="left" class="thinborderNONE"><%=vRetResult.elementAt(i + 5)%></td>
      <td class="thinborderNONE"><%=vRetResult.elementAt(i + 8)%></td>
      <td class="thinborderNONE"><%=vRetResult.elementAt(i + 9)%></td>
      <td class="thinborderNONE"><%=vRetResult.elementAt(i + 11)%></td>
      <td class="thinborderNONE"><%=vRetResult.elementAt(i + 12)%></td>
      <td class="thinborderNONE"><%=vRetResult.elementAt(i + 13)%></td>
      <td class="thinborderNONE"><%=CommonUtil.formatFloat(dRowTotalSubFee, true)%></td>
    </tr>
	<%}if( (i + 14) > vRetResult.size()) {%>
		<tr align="right">
		  <td height="24" align="left" class="thinborderNONE">&nbsp;</td>
		  <td align="left" class="thinborderNONE">&nbsp;</td>
		  <td align="left" class="thinborderNONE">&nbsp;</td>
		  <td class="thinborderNONE">&nbsp;</td>
		  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dTotalSub, true)%></td>
		  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dTotalTutorial, true)%></td>
		  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dTotalHandsOn, true)%></td>
		  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dTotalLab, true)%></td>
		  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dTotalSubFee, true)%></td>
		</tr>
	<%}%>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="69%" height="24"><font size="1">Printed by : <%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></font></td>
      <td width="12%">&nbsp;</td>
      <td width="19%">&nbsp;</td>
    </tr>
  </table>
<%}

}//////////////////// end of report ////////////////////%>
<input type="hidden" name="show_list">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
