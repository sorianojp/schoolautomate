<%@ page language="java" import="utility.*,purchasing.Requisition,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function ShowData(){	
    document.form_.show_data.value = "1";	
	document.form_.page_action.value = "";
 	document.form_.submit();
}
function checkAllSaveItems() {
	var maxDisp = document.form_.max_count.value;
	var bolIsSelAll = document.form_.selAllSaveItems.checked;
	for(var i =1; i<= maxDisp; ++i)
		eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
}

function ViewItem(strIndex,strSupply){
	var pgLoc = "requisition_view.jsp?req_no="+strIndex+"+&is_supply="+strSupply+"";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PageAction(strAction){
	document.form_.page_action.value = strAction;
	document.form_.show_data.value = "1";	
	document.form_.submit();
}

</script>
<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	
	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="requisition_view_search_print.jsp"/>
	<%return;}

//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-REQUISITION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
	}
	
	if(WI.fillTextValue("my_home").equals("1"))
		iAccessLevel = 2;
		
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-REQUISITION-Requisition Search","requisition_view_search.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	

	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
Requisition REQ = new Requisition(request);
Vector vRetResult = null;
int iElemCount = 0;


strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(!REQ.setReqStatusFinal(dbOP, request))
		strErrMsg = REQ.getErrMsg();
}



if(WI.fillTextValue("show_data").length() > 0){
	vRetResult = REQ.getReqInfoForFinalUpdate(dbOP, request);
	if(vRetResult == null){
		if(strErrMsg == null)
			strErrMsg = REQ.getErrMsg();
	}else
		iElemCount = REQ.getElemCount();
}	

%>
<form name="form_" method="post" action="./requisition_update_batch.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          REQUISITION : UPDATE  REQUISITION STATUS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="19%">Requisition No. : </td>
      <td width="78%"><select name="req_no_select">
          <%=REQ.constructGenericDropList(WI.fillTextValue("req_no_select"),astrDropListEqual,astrDropListValEqual)%> </select> <input type="text" name="req_num" class="textbox" value="<%=WI.fillTextValue("req_num")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Requisition Date :</td>
      <td>From:&nbsp; <input name="date_req_fr" type="text" value="<%=WI.fillTextValue("date_req_fr")%>" size="12" readonly="yes"  class="textbox"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_req_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        To:&nbsp; <input name="date_req_to" value="<%=WI.fillTextValue("date_req_to")%>" type="text" class="textbox" size="12" readonly="yes"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_req_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Requested By :</td>
      <td><select name="req_by_select">
          <%=REQ.constructGenericDropList(WI.fillTextValue("req_by_select"),astrDropListEqual,astrDropListValEqual)%> </select> <input type="text" name="req_by" class="textbox" value="<%=WI.fillTextValue("req_by")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%> :</td>
      <td><select name="c_index" onChange="ShowData();">
          <option value="">All</option>
          <%if(WI.fillTextValue("c_index").equals("0")){%>
          <option value="0" selected>Non-Academic Office</option>
          <%}else{%>
          <option value="0">Non-Academic Office</option>
          <%} 
			if(WI.fillTextValue("c_index").length() > 0)
				strTemp = WI.fillTextValue("c_index");
			else
				strTemp = "0";
			
			if(strTemp.compareTo("0") ==0)
				strTemp2 = "Offices";
			else
			strTemp2 = "Department";
			%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><%=strTemp2%></td>
      <td> <%String strTemp3 = null;
		if(strTemp.compareTo("0") ==0) //only if non college show others.
			strTemp2 = " onChange='ShowHideOthers(\"d_index\",\"oth_dept\",\"dept_\");'";
		else
			strTemp2 = "";
	  %> <select name="d_index">
          <option value="">All</option>
          <%if(WI.fillTextValue("c_index").length() < 1)
		 	strTemp="-1";
		 strTemp3 = WI.fillTextValue("d_index");%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and ("+WI.getStrValue(strTemp, "c_index=",""," c_index = 0 or c_index is null")+") order by d_name asc",strTemp3, false)%> </select></td>
    </tr>
    <tr>
        <td height="25">&nbsp;</td>
        <td>&nbsp;</td>
        <td><a href="javascript:ShowData();"><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
	<!--
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Request For :</td>
      <td height="25"> 
        <%if(WI.fillTextValue("supply").equals("1") || 
	  (WI.fillTextValue("opner_info").length() > 1 && WI.fillTextValue("nsupply").equals("1")))
	  		strTemp = "checked";
		else
			strTemp = "";%>
        <input type="checkbox" name="supply" value="1" <%=strTemp%>>
        Supply 
        <%if(WI.fillTextValue("non-supply").equals("0")|| 
	  (WI.fillTextValue("opner_info").length() > 1 && WI.fillTextValue("nsupply").equals("0")))
	 		strTemp = "checked";
		else
			strTemp = "";%>
	  <input type="checkbox" name="non-supply" value="0" <%=strTemp%>>
        Non-Supply 
        <%if(WI.fillTextValue("chemical").equals("2")|| 
	  (WI.fillTextValue("opner_info").length() > 1 && WI.fillTextValue("nsupply").equals("2")))
	 		strTemp = "checked";
		else
			strTemp = "";%>
        <input type="checkbox" name="chemical" value="2" <%=strTemp%>>
        Chemicals </td>
    </tr>
	-->
    <tr> 
      <td height="18" colspan="3">&nbsp;</td>
    </tr>
  </table>
	
  
<%if(vRetResult != null && vRetResult.size() > 0){
String[] astrReqStatus = {"Disapproved","Approved","Pending"};	
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td width="13%" height="25" align="center" class="thinborder"><strong style="font-size:10px;">REQUISITION NO</strong></td>
		<td width="14%" align="center" class="thinborder"><strong style="font-size:10px;">REQUEST DATE</strong></td>
		<td width="16%" align="center" class="thinborder"><strong style="font-size:10px;">COLLEGE/DEPT</strong></td>
		<td width="22%" align="center" class="thinborder"><strong style="font-size:10px;">REQUESTED BY</strong></td>
		<td width="12%" align="center" class="thinborder"><strong style="font-size:10px;">UPDATE STATUS</strong></td>
		<td width="13%" align="center" class="thinborder"><strong style="font-size:10px;">DATE OF APPROVAL</strong></td>
		<td width="6%" align="center" class="thinborder"><strong style="font-size:10px;">VIEW DETAIL</strong></td>
		<td width="4%" align="center" class="thinborder"><strong>Select<br />
		    All<br /></strong>
			<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();"></td>
	</tr>
	<%
	int iCount = 0;
	for(int i = 0 ; i < vRetResult.size() ; i+=iElemCount){
	%>
	 <tr>
	 	<td class="thinborder" height="20"><%=vRetResult.elementAt(i+1)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i+5)%></td>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i+2));
		if(strTemp.length() > 0)
			strTemp += "/ ";
		strTemp += WI.getStrValue(vRetResult.elementAt(i+3));	
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+4),"&nbsp;")%></td>
		<td class="thinborder">
		<select name="status_<%=(++iCount)%>">
		<%
		strTemp = WI.fillTextValue("status_"+iCount);
		if(strTemp.length() == 0)
			strTemp = "1";		
			
		for(int x = 0; x < astrReqStatus.length; x++){			
		if(strTemp.equals(Integer.toString(x)))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		
		%>
          <option value="<%=x%>" <%=strErrMsg%>><%=astrReqStatus[x]%></option>		
		<%}%>
        </select>
		</td>
		<%
		strTemp = WI.fillTextValue("date_updated_"+iCount);
		if(strTemp.length() == 0)
			strTemp = WI.getTodaysDate(1);
		%>
		<td class="thinborder" align="center">
		 <input name="date_updated_<%=iCount%>" type="text" size="10" value="<%=strTemp%>" maxlength="10" readonly="yes"  class="textbox"
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_updated_<%=iCount%>');" title="Click to select date" 
			onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
		</td>
		<td class="thinborder" align="center">
		<a href="javascript:ViewItem('<%=vRetResult.elementAt(i+1)%>','<%=vRetResult.elementAt(i+7)%>')"><img src="../../../images/view.gif" border="0"></a>
		</td>
		<td class="thinborder" align="center">
		<input type="checkbox" name="save_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" tabindex="-1">
		</td>
	 </tr>
	<%}%>
	<input type="hidden" name="max_count" value="<%=iCount%>">
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td align="center">
	<a href="javascript:PageAction('1');"><img src="../../../images/save.gif" border="0"></a>
	<font size="1">Click to finalize requisition status.</font>
	</td></tr>
</table>
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr><td width="4%" height="25" colspan="8">&nbsp;</td></tr>
<tr bgcolor="#B8CDD1"><td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
  <input type="hidden" name="show_data">
  <input type="hidden"  name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>