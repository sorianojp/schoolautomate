<%@ page language="java" import="utility.*, java.util.Vector" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head><style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
 }
th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
 }
-->
</style>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function RefreshPage(){
   document.form_.page_refresh.value="1";
   document.form_.submit();
}
function PageAction(strAction, strinfo){
	document.form_.page_action.value = strAction;
	if(strAction=='3'){
	  document.form_.prepareToEdit.value = '1';
	  document.form_.page_action.value = "";
	}
	if(strAction == '0'){
		if(!confirm("Do you want to delete this entry?"))
			return;
	}
	if(strinfo.length > 0)
	  document.form_.info_index.value = strinfo;
	document.form_.page_refresh.value="1";  	
	document.form_.submit();
}
function RemoveBatchFrmCurrent() {
	var pgLoc = "./manage_swu_current_batch.jsp";	
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=500,scrollbars=yes,top=10,left=10,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
    //add security here.

	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE","manage_swu_batch.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
        <p align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
		<%return;
	}
	
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"manage_swu_batch.jsp");
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
	
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");	
	strTemp = WI.fillTextValue("page_action");

	String[] astrSem ={"","1st Term","2nd Term","3rd Term","4th Term", "5th Term"};
	String[] astrMonth ={"January","February","March","April","May","June","July","August","September","October","November","December"};	
	
	enrollment.FAFeeMaintenance feeMaintenance =new enrollment.FAFeeMaintenance();
	
	Vector vRetResult = null;
	Vector vEditInfo = null;
	
	if(strTemp.length() > 0){
		if(feeMaintenance.operateOnSWUBatch(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = feeMaintenance.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Batch Information successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Batch Information successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "Batch Information successfully edited.";			
			strPrepareToEdit = "0";
		}
	 }
	 
     if(strPrepareToEdit.equals("1")){
		 vEditInfo = feeMaintenance.operateOnSWUBatch(dbOP, request,3);
		 if(vEditInfo == null)
			strErrMsg = feeMaintenance.getErrMsg();
	 }
		
	 vRetResult = feeMaintenance.operateOnSWUBatch(dbOP, request,4);
	 if(vRetResult == null)
		strErrMsg = feeMaintenance.getErrMsg();
%>
<form name="form_" action="manage_swu_batch.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6" align="center"><font color="#FFFFFF"><strong>::::
        BATCH NUMBER MANAGEMENT PAGE ::::</strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable">
    <tr>
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>	
	<!--<tr>
	  <td width="5%" height="25">&nbsp;</td>
	  <td>Student ID:</td>
	  <td>  <input name="stud_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("stud_id")%>" size="16"  onKeyUp="AjaxMapName('1');">
      <label id="coa_info" style="font-size:11px; position:absolute; width:300px; font-weight:bold; color:#0000FF"></label></td>
	</tr>-->
	<tr>
	<td width="5%">&nbsp;</td>
	<td width="11%">SY-TERM:</td>
      <td  colspan="2">
<%	
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>    <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>    <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
       <select name="semester">
          <option value="1">1st Term</option>
<%	if(vEditInfo != null && vEditInfo.size() > 0)
		  strTemp = (String)vEditInfo.elementAt(4);
	else	
	      strTemp =WI.fillTextValue("semester");
		  if(strTemp.length() ==0) 
			strTemp = (String)request.getSession(false).getAttribute("cur_sem");
			if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Term</option>
          <%}else{%>
          <option value="2">2nd Term</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Term</option>
          <%}else{%>
          <option value="3">3rd Term</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Term</option>
          <%}else{%>
          <option value="4">4th Term</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>5th Term</option>
          <%}else{%>
          <option value="5">5th Term</option>
          <%}%>
        </select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <a href="javascript:RefreshPage();"><img src="../../../images/refresh.gif" border="0" /></a>      </td>
	  <td width="38%" align="right">
	  <a href="javascript:RemoveBatchFrmCurrent();">Remove Batch From Currently In Use</a>
	  </td>
    </tr>
     <tr>
     <td width="5%" height="25">&nbsp;</td>
      <td>Batch No.</td>
	  <%  strTemp =WI.fillTextValue("batch_no");
		  if(vEditInfo != null && vEditInfo.size() > 0) {
			strTemp = (String)vEditInfo.elementAt(1);
		  }
      %>
      <td colspan="3">
	  <input name="batch_no" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=strTemp%>" size="16" maxlength="32">	  </td>
  </tr>
   
	<tr>
      <td width="5%" height="25">&nbsp;</td>
      <td width="11%">Month:</td>
      <td colspan="3">
	  <select name="month_from">
	  <%for(int i=0; i<astrMonth.length; i++){
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(2);		
			else	
				strTemp = WI.fillTextValue("month_from");	
				
			if(strTemp.equals(i+""))
				strErrMsg = " selected";
			else
				strErrMsg="";	
				
	   %>
	   <option value="<%=i%>" <%=strErrMsg%>><%=astrMonth[i]%></option>
	  <%}%>
	  </select>
	  to
	  <select name="month_to">
	   <%for(int i=0; i<astrMonth.length; i++){
			 if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(3);	
			 else	
				strTemp = WI.fillTextValue("month_to");	
				
			if(strTemp.equals(i+""))
				strErrMsg = " selected";
			else
				strErrMsg="";		
	    %>
	   <option value="<%=i%>" <%=strErrMsg%>><%=astrMonth[i]%></option>
	   <%}%>
	  </select>	  </td>
    </tr>
	<tr>
      <td colspan="5">&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
	  <td width="11%">&nbsp;</td>
      <td height="15" colspan="3"><div align="left">
<%if(strPrepareToEdit.equals("0")){%> 
		<a href="javascript:PageAction('1','');">
		<img src="../../../images/save.gif" border="0"></a> <font size="1">click to save entries </font>
<%}else{%>
        <a href="javascript:PageAction('2','');">
		<img src="../../../images/edit.gif" border="0"></a> <font size="1">click to edit entries </font>		
<%}%>	<a href="./batch_list.jsp">
		<img src="../../../images/cancel.gif" border="0" /></a><font size="1">click to cancel/clear entries</font>
		</div>      </td>
    </tr>
  </table>
<%if (vRetResult != null && vRetResult.size() > 0) { %>
  <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="20" colspan="6" bgcolor="#B9B292" class="thinborder">
	  <div align="center"><strong>::: BATCH NUMBER LISTING FOR <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%> ::: </strong></div></td>
    </tr>
    <tr>
      <td height="26" width="14%" class="thinborder" align="center"><strong>Batch No</strong></td>
      <td width="12%"  class="thinborder" align="center"><strong>Term</strong></td>
      <td width="12%"  class="thinborder" align="center"><strong>Month From</strong></td>
	  <td width="12%"  class="thinborder" align="center"><strong>Month To</strong></td>
	  <td width="18%"  class="thinborder" align="center"><strong>Options</strong></td>
    </tr>
	<%for(int i = 0; i < vRetResult.size(); i += 6){%>
    <tr>
      <td height="25"  class="thinborder" align="center"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td  class="thinborder"><%=astrSem[Integer.parseInt((String)vRetResult.elementAt(i+4))]%></td>
      <td height="25"  class="thinborder"><%=astrMonth[Integer.parseInt((String)vRetResult.elementAt(i+2))]%></td>
	   <td height="25"  class="thinborder"><%=astrMonth[Integer.parseInt((String)vRetResult.elementAt(i+3))]%></td>
	   <td  class="thinborder" align="center">
	   <a href="javascript:PageAction('3','<%=(String)vRetResult.elementAt(i)%>');"> 
	  <img src="../../../images/edit.gif" border="0" /></a>&nbsp;&nbsp;&nbsp;
	  <a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');"> 
	  <img src="../../../images/delete.gif" border="0" /></a>    </tr>
    <%}// end of vRetResult loop%>
  </table>
  <%} // end of vRetResult != null && vRetResult.size() > 0%>
  <table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable5">
    <tr bgcolor="#FFFFFF">
      <td height="25"></td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action">
  <input type="hidden" name="page_refresh">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="info_index" value="<%= WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
<%dbOP.cleanUP();%>
