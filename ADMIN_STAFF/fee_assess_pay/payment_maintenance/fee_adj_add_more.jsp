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
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.hide_save.src = "../../../images/blank.gif";
		
	document.form_.submit();
}
function CancelRecord() {
	location = "./fee_adj_add_more.jsp?fa_fa_index="+document.form_.fa_fa_index.value;
}
</script>


<body bgcolor="#D2AE72">
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
								"Admin/staff-Fee Assessment & Payments-PAYMENT MAINTENANCE-Fee adjustment type","fee_adj_add_more.jsp");
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
														"fee_adj_add_more.jsp");
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

FAPmtMaintenance FA = new FAPmtMaintenance();
Vector vRetResult = null;
Vector vMainAdjDetail = FA.viewOneFeeAdjustment(dbOP, 0, WI.fillTextValue("fa_fa_index"));
if(vMainAdjDetail == null) 
	strErrMsg = FA.getErrMsg();
else {
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(FA.operateOnMultipleFeeAdjustment(dbOP, request, Integer.parseInt(strTemp), WI.fillTextValue("fa_fa_index")) != null )
			strErrMsg = "Operation successful.";
		else	
			strErrMsg = FA.getErrMsg();
	}
	vRetResult = FA.operateOnMultipleFeeAdjustment(dbOP, request,4, WI.fillTextValue("fa_fa_index"));
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = FA.getErrMsg();
}
String[] astrConvertSem = {"SUMMER", "1ST SEM","2ND SEM","3RD SEM","4TH SEM","ALL SEM"};
%>

<form name="form_" action="./fee_adj_add_more.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          FEE ADJUSTMENT ADD MORE ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td colspan="2"><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
<%
if(vMainAdjDetail == null) {
	dbOP.cleanUP();
	return;
}%>	
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="26%">GRANT NAME</td>
      <td width="71%"><%=(String)vMainAdjDetail.elementAt(10)%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>SY-TERM</td>
      <td><%=astrConvertSem[Integer.parseInt(WI.getStrValue((String)vMainAdjDetail.elementAt(7),"5"))]%>,
	  <%=(String)vMainAdjDetail.elementAt(8) + " - "+(String)vMainAdjDetail.elementAt(9)%></td>
    </tr>
  </table>
<input type="hidden" name="sy_from" value="<%=vMainAdjDetail.elementAt(8)%>">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="3" style="font-size:11px; font-weight:bold; color:#0000FF">
	  <input type="checkbox" name="add_all_lab" value="1"> Add ALL Fee name with LAB 
	  <input type="checkbox" name="add_all" value="1"> Add All Fee names </td>
      <td>    
    </tr>
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="26%">MISC/ OTH FEE NAME</td>
      <td width="71%" colspan="2"><select name="fee_name">
<%=dbOP.loadCombo("distinct fee_name,fee_name","MISC_OTHER_CHARGE"," from fa_misc_fee join fa_schyr on (fa_schyr.sy_index = fa_misc_fee.sy_index) where is_del=0 and is_valid=1 and sy_from = "+
	(String)vMainAdjDetail.elementAt(8)+
	" and not exists (select * from FA_FEE_ADJUSTMENT_EXTN where FA_FEE_ADJUSTMENT_EXTN.fee_name = fa_misc_fee.fee_name and fa_fa_index = "+
		WI.fillTextValue("fa_fa_index")+" and is_valid = 1 ) order by MISC_OTHER_CHARGE,fa_misc_fee.fee_name asc", WI.fillTextValue("fee_name"), false)%> </select> </td>
	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top">DISCOUNT</td>
      <td colspan="2"> 
<%
strTemp = WI.fillTextValue("discount");
%> <input name="discount" type="text" size="8" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="discount_unit">
          <option value="0">amount</option>
          <%
strTemp = WI.fillTextValue("discount_unit");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>%</option>
          <%}else{%>
          <option value="1">%</option>
          <%}%>
        </select> <font size="1">(Set to amount = 0 if stud has to pay for specific 
        fee)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" valign="top" style="font-size:9px; font-weight:bold">
	  NOTE : <br>
	  1. Set to amount if student has to pay. if amount is set to 0, studnet pays whole amount for the set fee. <br>
	  For example : ID Fee, 100Amt and Discount is 1,000.00, then student will get total discount of 1,000.00 - 100 = 900.00 <br>
	  but if it is set ID Fee, 0Amt (ID fee is 250) , then student will get total discount of 1,000 - 250.00 = 750.00
	  <br>
	  2. Set to %ge if student has additional discount. <br>
	  For example : ID Free, 50% (ID fee is 250), then student will get total discount of 1,000.00 + 125.00 = 1,125.00	  </td>
    </tr>
  </table>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
if(iAccessLevel > 1){%>
    <tr> 
      <td  width="3%"height="25">&nbsp;</td>
      <td width="97%" colspan="3"> <a href='javascript:PageAction("1","");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        <font size="1" face="Verdana, Arial, Helvetica, sans-serif">click to add 
        entry </font><a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
        <font size="1">click to reset all entries.</font></td>
    </tr>
<%
	}//if iAccessLevel > 1
%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="100%" height="25" colspan="5" bgcolor="#B9B292"><div align="center">LIST 
          OF ADDITIONAL ADJUSTMENT</div></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr > 
      <td width="64%" height="25" class="thinborder"><div align="center"><strong><font size="1">FEE 
          NAME</font></strong></div></td>
      <td width="20%" class="thinborder"><div align="center"><strong><font size="1"> DISCOUNTS</font></strong></div></td>
      <td width="16%" class="thinborder" align="center"><strong><font size="1">DELETE</font></strong></td>
    </tr>
    <%
for(int i=1; i< vRetResult.size();i += 4){%>
    <tr > 
      <td height="25" class="thinborder">&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%><%=(String)vRetResult.elementAt(i+3)%> </td>
      <td align="center" class="thinborder"> <%if(iAccessLevel ==2){%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        Not authorized 
        <%}%></td>
    </tr>
<%}//end of for loop%>
  </table>
<%}//end if vRetResult.size() > 0)%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="info_index" value="">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="fa_fa_index" value="<%=WI.fillTextValue("fa_fa_index")%>">


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>