<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPage() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
</script>
<body>
<%@ page language="java" import="utility.*,enrollment.FAPmtMaintenance,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT MAINTENANCE-Fee adjustment type","fee_adjustment_type_print.jsp");
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
														"Fee Assessment & Payments","PAYMENT MAINTENANCE",request.getRemoteAddr(),
														"fee_adjustment_type_print.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = null;
FAPmtMaintenance pmtMaintenance = new FAPmtMaintenance();
if(WI.fillTextValue("sy_from").length() > 0) 
	vRetResult = pmtMaintenance.printAdjustment(dbOP, request);

%>
<form name="form_" action="./fee_adjustment_type_print.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: FEE ADJUSTMENT PRINTPAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td colspan="3"><strong><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="8%">SY-Term</td>
      <td width="41%">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        - 
        <select name="semester" onChange="ReloadPage();">
          <option value="">All Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("sy_from").length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.equals("0")){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}if(strTemp.equals("1")){%>
          <option value="1" selected>1st Sem</option>
<%}else{%>
          <option value="1">1st Sem</option>
<%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
<%}else{%>
          <option value="2">2nd Sem</option>
<%}
if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
<%}else{%>
          <option value="3">3rd Sem</option>
<%}%>
        </select></td>
      <td width="49%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="top">Number of Rows Per Page : 
		<select name="rows_per_pg">
	  	<%
		int iDefVal = 0;
		strTemp = WI.fillTextValue("rows_per_pg");
		if(strTemp.length() == 0) 
			iDefVal = 40;
		else	
			iDefVal = Integer.parseInt(strTemp);
		for(int i =30; i < 75; ++i){%>
			<option value="<%=i%>"<%=strErrMsg%>><%=i%></option>
		<%}%>
	  	</select>	  
	  </td>
      <td><input name="image" type="image" src="../../../images/form_proceed.gif">
	  <%if(vRetResult != null && vRetResult.size() > 0) {%>
	  <div align="right"><a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a></div>
	  <%}%>
	  </td>
    </tr>
</table>
<%if(vRetResult != null && vRetResult.size() > 0){
String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="100%" align="center" style="font-weight:bold">List of Fee Adjustment For <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>, <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></td>
    </tr>
  </table>
<%
String[] astrConvertDiscountType = {"","","","","","","","","","","","","","",""};//can accomodate 15.. 
strTemp = "select DISC_TYPE, DISC_NAME from FA_FEE_ADJUSTMENT_DIS_TYPE where disc_type > 0 order by DISC_TYPE";
java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
while(rs.next())
	astrConvertDiscountType[rs.getInt(1)] = rs.getString(2);	
rs.close();

Vector vTemp = null;

int iLinePrinted = 0;
int iLinePerPg = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_pg"), "40") );

int iTotalPages = (vRetResult.size()/12)/iLinePerPg;
if( (vRetResult.size()/12)%iLinePerPg > 0)
	++iTotalPages;
	
int iCurPage = 0;
//String[] astrConvertDiscountType={"","Academic","Athletic"};
for(int i=0; i< vRetResult.size(); ){
	iLinePrinted = 0;
	++iCurPage;
if(iCurPage > 1){%><DIV style="page-break-before:always" >&nbsp;</DIV><%}
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td align="right" style="font-size:9px;">Page <%=iCurPage%> of <%=iTotalPages%> &nbsp;</td></tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr > 
      <td width="35%" height="25" class="thinborder"><strong><font size="1">NAME</font></strong></td>
      <td width="10%" class="thinborder"><strong><font size="1">DISCOUNT</font></strong></td>
      <td width="15%" class="thinborder"><strong><font size="1">DISCOUNT ON </font></strong></td>
      <td width="27%" class="thinborder"><strong><font size="1">ADDITIONAL DISCOUNT</font></strong></td>
      <td width="8%" class="thinborder"><strong><font size="1">NON SCH FEE</font></strong></td>
      <td width="5%" class="thinborder"><strong><font size="1">MAX UNITS</font></strong></td>
      <td width="5%" class="thinborder"><strong><font size="1"> ALL SEM?</font></strong></td>
    </tr>
<%
for(; i< vRetResult.size(); i += 13){
	vTemp = pmtMaintenance.operateOnMultipleFeeAdjustment(dbOP, request, 4, (String)vRetResult.elementAt(i + 11));

if(vRetResult.elementAt(i) != null){%>
    <tr >
      <td height="25" colspan="7" class="thinborder" style="font-size:12px; font-weight:bold">&nbsp;&nbsp;&nbsp;&nbsp;<%=astrConvertDiscountType[Integer.parseInt((String)vRetResult.elementAt(i))]%></td>
    </tr>
<%}//show discount_type..
if(vRetResult.elementAt(i + 1) != null && vRetResult.elementAt(i + 2) != null && false){%>	
    <tr >
      <td colspan="7" class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <%=vRetResult.elementAt(i + 1)%><%=WI.getStrValue((String)vRetResult.elementAt(i + 2), " ::: ", "","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 3), " ::: ", "","")%><%=WI.getStrValue((String)vRetResult.elementAt(i + 4), " ::: ", "","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 5), " ::: ", "","")%><%=WI.getStrValue((String)vRetResult.elementAt(i + 6), " ::: ", "","")%>	  </td>
    </tr>
<%}
if(vRetResult.elementAt(i + 6) != null)
	strTemp = (String)vRetResult.elementAt(i + 6);
else if(vRetResult.elementAt(i + 5) != null)
	strTemp = (String)vRetResult.elementAt(i + 5);
else if(vRetResult.elementAt(i + 4) != null)
	strTemp = (String)vRetResult.elementAt(i + 4);
else if(vRetResult.elementAt(i + 3) != null)
	strTemp = (String)vRetResult.elementAt(i + 3);
else if(vRetResult.elementAt(i + 2) != null)
	strTemp = (String)vRetResult.elementAt(i + 2);
else
	strTemp = (String)vRetResult.elementAt(i + 1);
%>
    <tr > 
      <td height="25" class="thinborder"><%=strTemp%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+7)%> </td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+8)%> </td>
<%
if(vTemp != null)
	strTemp = (String)vTemp.elementAt(0);
else	
	strTemp = "&nbsp;";
%>
      <td valign="top" class="thinborder"><%=strTemp%></td>
      <td align="center" class="thinborder">&nbsp; 
	  <%  if( (WI.getStrValue((String)vRetResult.elementAt(i+9))).equals("1")){%> 
	  				<img src="../../../images/tick.gif"> <%}%>	  </td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+12), "&nbsp;")%></td>
      <td align="center" class="thinborder">&nbsp;
        <%if(vRetResult.elementAt(i + 10) == null){%> <img src="../../../images/tick.gif"><%}%></td>
    </tr>
<%
++iLinePrinted;
if(iLinePrinted >=iLinePerPg)
	 break;
}//end of inner for loop..%>
  </table>
<%}//end of outer for loop.. 


}//end of if(vRetResult is not null... 
%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>