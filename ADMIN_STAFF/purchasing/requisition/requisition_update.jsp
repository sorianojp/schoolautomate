<%@ page language="java" import="utility.*,purchasing.Requisition,java.util.Vector"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

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
function ProceedClicked(){
	document.form_.print_page.value = "";
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function SaveStatus(){
	document.form_.saveClicked.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function PageLoad(){
	document.form_.req_no.focus();
}
function PrintPage(){
	document.form_.saveClicked.value = "";
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
}
function OpenSearch(strSupply){
	document.form_.print_page.value = "";
	var pgLoc = "../requisition/requisition_view_search.jsp?opner_info=form_.req_no&is_supply=form_.is_supply&nsupply="+strSupply;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ForwardToStage(strStage){	
	location = "./requisition_update.jsp?proceedClicked=1&req_no="+document.form_.req_no.value+
						"&stage="+strStage;
}

</script>
<%
//add security here.
	if(WI.fillTextValue("print_page").equals("1")){%>
		<jsp:forward page="req_item_print.jsp"/>
	<%return;}
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-REQUISITION STATUS UPDATE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-UPDATE REQUISITION"),"0"));
		}
	}
	
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
	DBOperation dbOP = null;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-REQUISITION STATUS UPDATE-Requisition Update","requisition_update.jsp");
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
	
	Requisition REQ = new Requisition();	
	Vector vReqInfo = null;
	Vector vReqItems = null;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String strErrMsg = null;
	String strTemp = null;
	String strReqIndex = WI.fillTextValue("req_index");
	String strSchCode = dbOP.getSchoolIndex();
	
	boolean bolIsInPO = false;
	int iStatus = 0;
	if(strSchCode.startsWith("UDMC"))
		iStatus = 4;
	else
		iStatus = 3;
 
	if(WI.fillTextValue("proceedClicked").length() > 0){
		if(WI.fillTextValue("saveClicked").equals("1")){
			if(REQ.setReqStatus(dbOP,request))
				strErrMsg = "Status saved.";
			else
				strErrMsg = REQ.getErrMsg();
		}
		
		if(WI.fillTextValue("req_no").length() > 0){
			vReqInfo = REQ.operateOnReqInfo(dbOP,request,3);
			if(vReqInfo == null && WI.fillTextValue("req_no").length() > 0
								&& WI.fillTextValue("pageAction").length() < 1)
				strErrMsg = REQ.getErrMsg();
			else{
				strReqIndex = (String)vReqInfo.elementAt(0);			
				strTemp = dbOP.mapOneToOther("pur_po_info","requisition_index",strReqIndex,
											 "count(*)"," and is_del = 0");
				  if (Integer.parseInt(strTemp) > 0){
					bolIsInPO = true;
				  }
				}						 
			
			vReqItems = REQ.operateOnReqItems(dbOP,request,5);
			if(vReqItems == null)
				strErrMsg = "No item(s) for this Requisition.";
	   }else{
		   strErrMsg = "Please input requisition No.";			
	   }
	}
	
	
String strStage = WI.fillTextValue("stage");
///if system is set to 2nd level apprval, force stage to 4.
String strSQLQuery = "select prop_val from read_property_file where prop_name = 'ENABLE_2ND_APPROVAL_PO'";
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null && (strSQLQuery.equals("1") || strSQLQuery.equals("3")))
	strStage = "4";

%>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<form name="form_" method="post" action="./requisition_update.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A"> 
			<td height="25" align="center" bgcolor="#A49A6A"><font color="#FFFFFF"><strong>:::: 
			REQUISITION : UPDATE  REQUISITION STATUS PAGE ::::</strong></font></td>
		</tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="40">&nbsp;</td>
      <td width="21%">Requisition No.</td>
      <td valign="middle"><strong>
	  <%if(WI.fillTextValue("req_no").length() > 0)
	  		strTemp = WI.fillTextValue("req_no");
	  	else
			strTemp = "";%>
      <input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </strong>&nbsp;
		<a href="javascript:OpenSearch(<%=WI.fillTextValue("is_supply")%>);">
		<img src="../../../images/search.gif" border="0"></a>
		&nbsp;		 
		<a href="javascript:ProceedClicked();"> 
		<img src="../../../images/form_proceed.gif" border="0">
      </a></td>
    </tr>
  </table>
  <%if(vReqInfo != null){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="4" align="center"><strong>REQUISITION DETAILS </strong></td>
    </tr>
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td width="21%">Requisition No. :</td>
      <td width="28%"><strong><%=WI.fillTextValue("req_no")%></strong></td>
      <td width="20%">Requested by :</td>
      <td width="28%"> <strong><%=(String)vReqInfo.elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(1))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=(String)vReqInfo.elementAt(5)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(10))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(7)%></strong></td>
    </tr>
	<%if(((String)vReqInfo.elementAt(3)).equals("0")){%> 
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Office :</td>
      <td><strong><%=(String)vReqInfo.elementAt(9)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></strong></td>
    </tr>
	<%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(8)+"/"+WI.getStrValue((String)vReqInfo.elementAt(9),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></strong></td>
    </tr>
	<%}%>	
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%if(strSchCode.startsWith("UDMC") || strSchCode.startsWith("AUF")){%>
		<tr>
      <td height="10">
			<%if(!strStage.equals("1")){%>
			<a href="javascript:ForwardToStage('1');">Dept. head approval&nbsp;</a>
			<%}else{%>
				Dept. head approval&nbsp;
			<%}%>
			<%if(!strStage.equals("2")){%>
			<a href="javascript:ForwardToStage('2');">Inventory Department approval</a>
			&nbsp;
			<%}else{%>
			Inventory department approval
			&nbsp;
			<%}%>
			<%if(!strStage.equals("3")){%>
			<a href="javascript:ForwardToStage('3');">Overall Head</a>
			<%}else{%>
			Overall Head
			<%}%>
			</td>
    </tr>
		<%}%>
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <%if(vReqItems != null){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">    
	  <tr>
				<td width="100%" height="25" align="center" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT"><font color="#FFFFFF"><strong>LIST 
					OF REQUESTED ITEMS</strong></font></td>
	  </tr>	  
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr> 
      <td width="5%" height="25" align="center" class="thinborder"><strong>ITEM#</strong></td>
      <td width="6%" align="center" class="thinborder"><strong>QUANTITY</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="13%" align="center" class="thinborder"><strong>ITEM</strong></td>
      <td width="23%" align="center" class="thinborder"><strong>PARTICULARS/ITEM 
      DESCRIPTION </strong></td>
      <td width="15%" align="center" class="thinborder"><strong>SUPPLIER</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>UNIT PRICE</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>AMOUNT</strong></td>
    </tr>
    <%for(int iLoop = 2;iLoop < vReqItems.size();iLoop+=9){%>
    <tr> 
      <td  height="25" align="center" class="thinborder"><%=(iLoop+9)/9%></td>
      <td align="center" class="thinborder"><%=(String)vReqItems.elementAt(iLoop+1)%></td>
      <td class="thinborder"><%=(String)vReqItems.elementAt(iLoop+2)%></td>
      <td class="thinborder"><%=(String)vReqItems.elementAt(iLoop+3)%></td>
      <td class="thinborder"><%=(String)vReqItems.elementAt(iLoop+4)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+5),"&nbsp;")%></td>
      <td align="right" class="thinborder"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+6),"&nbsp;")%></td>
      <td align="right" class="thinborder">
	  	<%if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0")){%>
	 		&nbsp;
		  <%}else{%>
			<%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%>
		  <%}%></td>
    <%}%>
    <tr> 
      <td height="25" colspan="5" class="thinborder"><strong>TOTAL 
          ITEM(S) : <%=(String)vReqItems.elementAt(0)%></strong></td>
      <td colspan="2" align="right" class="thinborder"><strong>TOTAL 
          AMOUNT :&nbsp;</strong></td>
      <td align="right" class="thinborder"><strong><%=vReqItems.elementAt(1)%></strong></td>
    </tr>
  </table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="23" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td width="8%" height="25">&nbsp;</td>
      <td colspan="2"><a href="javascript:PrintPage();"> <img src="../../../images/print.gif" border="0"></a><font size="1">Print Items per page</font> 
          <select name="num_rows">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rows"),"15"));
				for(int i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>

	  </td>
    </tr>
<%if(strStage.equals("1")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Recommending Approval by
        <% if(bolIsSchool){%>
        Dean/
        <%}%>
      Head:</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="40%">
			<%
			if(vReqInfo != null)
				strTemp = (String)vReqInfo.elementAt(10);
			else
				strTemp = "3";		
			%>
        <select name="status">
					<%for(int i = 0;i < iStatus; i++){%>
					<%if(strTemp.equals(Integer.toString(i))){%>
          <option value="<%=i%>" selected><%=astrReqStatus[i]%></option>
					<%}else{%>
					<option value="<%=i%>"><%=astrReqStatus[i]%></option>
					<%}%>
					<%}%>
        </select></td>
      <td width="52%">Date Updated :
        <%if(vReqInfo != null && (((String)vReqInfo.elementAt(11)) != null))
			strTemp = (String)vReqInfo.elementAt(11);		
		 else if(WI.fillTextValue("date_updated").length() > 0)
	  		strTemp = WI.fillTextValue("date_updated");
		 else
			strTemp = WI.getTodaysDate(1);
	  %>
        <input name="date_updated" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_updated');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
<%}%>
<%if(strStage.equals("4")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>First Level Approval: </td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="40%">
			<%
			strTemp = null;
			if(vReqInfo != null) {
				strTemp = (String)vReqInfo.elementAt(20);
				if(strTemp != null && strTemp.equals("3") && vReqInfo.elementAt(21) == null)
					strTemp = "2";
			}
			strTemp = WI.getStrValue(strTemp,"2");					
			%>
        <select name="inv_dept_stat">
					<%for(int i = 0;i < iStatus; i++){%>
					<%if(strTemp.equals(Integer.toString(i))){%>
          <option value="<%=i%>" selected><%=astrReqStatus[i]%></option>
					<%}else{%>
					<option value="<%=i%>"><%=astrReqStatus[i]%></option>
					<%}%>
					<%}%>
        </select></td>
      <td width="52%">Date Updated :
      <%
			 if(vReqInfo != null && (((String)vReqInfo.elementAt(21)) != null))
				strTemp = (String)vReqInfo.elementAt(21);		
			 else if(WI.fillTextValue("inv_dept_date").length() > 0)
					strTemp = WI.fillTextValue("inv_dept_date");
			 else
				strTemp = WI.getTodaysDate(1);
			%>
        <input name="inv_dept_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.inv_dept_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
<%}%>
  	<%if(strSchCode.startsWith("UDMC") || strSchCode.startsWith("AUF")){%>
		<%if(strStage.equals("2")){%>
	  <tr>
      <td height="25">&nbsp;</td>
      <td>Approval by Inventory/purchasing department </td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>
			<%
			strTemp = null;
			if(vReqInfo != null)
				strTemp = (String)vReqInfo.elementAt(20);

			strTemp = WI.getStrValue(strTemp,"2");		
			%>
        <select name="inv_dept_stat">
          <%for(int i = 0;i < iStatus; i++){%>
          <%if(strTemp.equals(Integer.toString(i))){%>
          <option value="<%=i%>" selected><%=astrReqStatus[i]%></option>
          <%}else{%>
          <option value="<%=i%>"><%=astrReqStatus[i]%></option>
          <%}%>
          <%}%>
        </select></td>
      <td>Date Updated :
      <%
			 if(vReqInfo != null && (((String)vReqInfo.elementAt(21)) != null))
				strTemp = (String)vReqInfo.elementAt(21);		
			 else if(WI.fillTextValue("inv_dept_date").length() > 0)
					strTemp = WI.fillTextValue("inv_dept_date");
			 else
				strTemp = WI.getTodaysDate(1);
			%>
        <input name="inv_dept_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.inv_dept_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
		<%}%>
		<%if(strStage.equals("3")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Approval by overall head </td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>
			<%
			strTemp = null;
			if(vReqInfo != null)
				strTemp = (String)vReqInfo.elementAt(22);

			strTemp = WI.getStrValue(strTemp,"2");
			%>
        <select name="stat_overall">
          <%for(int i = 0;i < iStatus; i++){%>
          <%if(strTemp.equals(Integer.toString(i))){%>
          <option value="<%=i%>" selected><%=astrReqStatus[i]%></option>
          <%}else{%>
          <option value="<%=i%>"><%=astrReqStatus[i]%></option>
          <%}%>
          <%}%>
        </select></td>
      <td>Date Updated :
        <%if(vReqInfo != null && (((String)vReqInfo.elementAt(23)) != null))
			strTemp = (String)vReqInfo.elementAt(23);		
		 else if(WI.fillTextValue("date_overall").length() > 0)
	  		strTemp = WI.fillTextValue("date_overall");
		 else
			strTemp = WI.getTodaysDate(1);
	  %>
        <input name="date_overall" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_overall');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
		<%}%>
		<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><%if(vReqInfo != null)
			strTemp = (String)vReqInfo.elementAt(10);
		strTemp = WI.getStrValue(strTemp,"0");		
	  	 if(!strTemp.equals("1") || !bolIsInPO){
	  %>
        <font size="1"><a href="javascript:SaveStatus();"> <img src="../../../images/save.gif" border="0"></a>click 
        to save update</font>
        <%}else{%>
PO already created
<%}%></td>
    </tr>
  </table>
  <%}}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="is_supply" value="<%=WI.fillTextValue("is_supply")%>">
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="saveClicked" value="">
  <input type="hidden" name="req_index" value="<%=strReqIndex%>">
  <input type="hidden" name="print_page">
	<input type="hidden" name="stage" value="<%=strStage%>">	
	<input type="hidden" name="forwardTo">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>