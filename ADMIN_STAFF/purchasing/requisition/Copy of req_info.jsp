<%@ page language="java" import="utility.*,purchasing.Requisition,java.util.Vector" %>
<%  
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
<script language="JavaScript">
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.pageAction.value = "";
	document.form_.forwardTo.value = "";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage()
{		
    document.form_.forwardTo.value = "";
	document.form_.printPage.value = "";
	document.form_.pageReloaded.value = "1";
	document.form_.pageAction.value = "1";	
	this.SubmitOnce('form_');
}
function PageAction(strAction,strIndex){
	document.form_.pageAction.value = "";
	document.form_.forwardTo.value = "";
	document.form_.printPage.value = "";
	if(strAction == 0){
		var vProceed = confirm('Delete this PO?');
		if(vProceed){
			document.form_.pageAction.value = strAction;
			document.form_.strIndex.value = strIndex;
			this.SubmitOnce('form_');
		}		
	}
	else{
		document.form_.pageAction.value = strAction;
		document.form_.strIndex.value = strIndex;
		this.SubmitOnce('form_');	
	}
} 
function ForwardTo(){
	document.form_.forwardTo.value = "1";
	document.form_.pageAction.value = "";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
    document.form_.forwardTo.value = "";
	document.form_.pageAction.value = "";
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
function OpenSearch(strSupply){
	document.form_.printPage.value = "";
	var pgLoc = "../requisition/requisition_view_search.jsp?opner_info=form_.req_no&is_supply=form_.is_supply&nsupply="+strSupply+
				"&my_home="+document.form_.my_home.value;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageLoad(){
 	document.form_.req_no.focus();
}
function UpdatePOSignatory(){
	var pgLoc = "../purchase_order/purchasing_officers.jsp?sign_type=0";
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<%	
	String strTemp = null;
	boolean bolMyHome = false;	
	
	if (WI.fillTextValue("my_home").equals("1")) 
		bolMyHome = true;
		
	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="req_item_print.jsp"/>
	<%return;}
	 if(WI.fillTextValue("forwardTo").equals("1")){%>
		<jsp:forward page="req_item.jsp"/>
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

strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){//for my home, request items... i doubt someone will look at this anyway... hehehe
			iAccessLevel  = 2;	
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
								"Admin/staff-PURCHASING-REQUISITION-Requisition Info","req_info.jsp");
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
	Vector vRetResult = null;
	Vector vEmpDetails = null;
	String strErrMsg = null;	
	String strTemp2 = null;
	String strCIndex = null;
	String strDIndex = null;
	String strReqName = null;
	int iDefault = 0;
	String strSchCode = dbOP.getSchoolIndex();	
	boolean bolShowPOSign = false;
	String[] astrSupplyVal = {"0","1","2","3"};
	String[] astrSupplyType = {"Non-Supplies / Equipmment","Supplies","Chemical","Computers/Parts"};
	
	if(WI.fillTextValue("proceedClicked").equals("1")){	
		if(WI.fillTextValue("pageAction").length() > 0 && !(WI.fillTextValue("pageReloaded").equals("1"))){
			vRetResult = REQ.operateOnReqInfo(dbOP,request,
						   Integer.parseInt(WI.fillTextValue("pageAction")));	
			if(vRetResult == null)
				strErrMsg = REQ.getErrMsg();
			else
				strErrMsg = "Operation successful";								
		}		
		vReqInfo = REQ.operateOnReqInfo(dbOP,request,3);
		if(vReqInfo == null && WI.fillTextValue("req_no").length() > 0
							&& WI.fillTextValue("pageAction").length() < 1)
			strErrMsg = REQ.getErrMsg();
			
		vReqItems = REQ.operateOnReqItems(dbOP,request,4);
		if(bolMyHome){
			vEmpDetails = REQ.getEmployeeDetail(dbOP,request);
			if(vEmpDetails != null && vEmpDetails.size() > 0){
			  strCIndex = (String)vEmpDetails.elementAt(4);	
			  strDIndex = (String)vEmpDetails.elementAt(5);
			  strReqName = WI.formatName((String)vEmpDetails.elementAt(1),(String)vEmpDetails.elementAt(2),
			  							(String)vEmpDetails.elementAt(3),4);
			}
		}
	}		
%>
<form name="form_" method="post" action="./req_info.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">    
	  <%if(WI.fillTextValue("is_supply").equals("0")){%>
	  <tr bgcolor="#A49A6A">
      <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          REQUISITION : ENCODE NON-SUPPLIES/EQUIPMENT REQUISITION PAGE ::::</strong></font></div></td>
	  </tr>
	  <%}else{%>
	  <tr bgcolor="#A49A6A">	  
	  <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          REQUISITION : ENCODE SUPPLIES REQUISITION PAGE ::::</strong></font></div></td>
	  </tr>
	  <%}%>    
    <tr bgcolor="#FFFFFF"> 
      <td width="69%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%>        
        </font></strong></td>
      <td width="31%"><div align="right">
          <%if((vReqInfo != null && vReqInfo.size() > 0) || (vRetResult != null && vRetResult.size() > 0)){%>
          <a href="javascript:ForwardTo();"><font size="2">Click to add requisition 
          items</font></a> 
          <%}%>
        </div></td>     
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="21%">Requisition No.</td>
      <td><strong>
	  <%if(WI.fillTextValue("pageAction").equals("1") && vRetResult != null)
	  		strTemp = (String)vRetResult.elementAt(0);
	    else if(WI.fillTextValue("req_no").length() > 0)
	  		strTemp = WI.fillTextValue("req_no");
	  	else
			strTemp = "";
	  %>
        <input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </strong>&nbsp; 
		<a href="javascript:OpenSearch(<%=WI.fillTextValue("is_supply")%>);">
		<img src="../../../images/search.gif" border="0"></a>
		<a href="javascript:ProceedClicked();"> <img src="../../../images/form_proceed.gif" border="0"> 
        </a></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">NOTE: <br>
        1. To create new requisition, click proceed. New requisition number will 
        be given after clicking SAVE.<br>
        2. To edit requisition information, enter old requisition number and click 
        proceed. </td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <%if(WI.fillTextValue("proceedClicked").equals("1")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<!--
    <tr>
      <td height="26">&nbsp;</td>
      <td>Inventory Type</td>
      <td colspan="3">
	    <select name="is_supply" onChange="ReloadPage();">		  
          <option value="0"><%=astrSupplyType[0]%></option>
		<%for(int i = 1; i < 4; i++){%>
          <%if(WI.fillTextValue("is_supply").equals(Integer.toString(i))){%>
          <option value="<%=i%>" selected><%=astrSupplyType[i]%></option>
          <%}else{%>
          <option value="<%=i%>"><%=astrSupplyType[i]%></option>
          <%}%>
		<%}%>
        </select></td>
    </tr>
	-->
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="21%">Request Type</td>
      <td colspan="3"> 
	   <%if(vReqInfo != null && vReqInfo.size() > 1 && !(WI.fillTextValue("pageReloaded").equals("1")))
			strTemp = (String)vReqInfo.elementAt(1);
		  else
			strTemp = WI.fillTextValue("req_type");	  
		%> <select name="req_type">
          <option value="0">New</option>
          <%if(strTemp.equals("1")){%>
          <option value="1" selected>Replacement</option>
          <%}else{%>
          <option value="1">Replacement</option>
          <%}%>
        </select></td>
    </tr>
    <%if(!bolMyHome){%>
	<tr> 
      <td height="26">&nbsp;</td>
      <td>Requested By </td>
      <td colspan="3"> <% if(vReqInfo != null && vReqInfo.size() > 1 && !(WI.fillTextValue("pageReloaded").equals("1")))
	   	  	strTemp = (String)vReqInfo.elementAt(2);
		  else if(WI.fillTextValue("requested_by").length() > 0)
			strTemp = WI.fillTextValue("requested_by");
		  else
			strTemp = "";		
		%> <input name="requested_by" type="text" size="50" class="textbox" value="<%=strTemp%>"
	     onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>College</td>
      <td colspan="3"><select name="c_index" onChange="ReloadPage();">
          <option value="0">N/A</option>
          <%
			if(vReqInfo != null && vReqInfo.size() > 1 && !(WI.fillTextValue("pageReloaded").equals("1")))
				strTemp = (String)vReqInfo.elementAt(3);
			else if(WI.fillTextValue("c_index").length() > 0)
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
      <td height="29">&nbsp;</td>
      <td><%=strTemp2%></td>
      <td height="29"> <%String strTemp3 = null;
		if(strTemp.compareTo("0") ==0) //only if non college show others.
			strTemp2 = " onChange='ShowHideOthers(\"d_index\",\"oth_dept\",\"dept_\");'";
		else
			strTemp2 = "";
	  %> <select name="d_index">
          <%
		if(strTemp.compareTo("0") ==0){//only if from non college.%>
          <option value="0">Select Office</option>
          <%}else{%>
          <option value="">All</option>
          <%}
		strTemp3 = "";
		if(vReqInfo != null && vReqInfo.size() > 0&& !(WI.fillTextValue("pageReloaded").equals("1")))
			strTemp3 = (String)vReqInfo.elementAt(4);
		else
			strTemp3 = WI.fillTextValue("d_index");
		%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and ("+WI.getStrValue(strTemp, "c_index=",""," c_index = 0 or c_index is null")+") order by d_name asc",strTemp3, false)%> </select> </td>
    </tr>
	<%}// end of my home calling
	else{%>
		<input type="hidden" name="c_index" value="<%=strCIndex%>">
		<input type="hidden" name="d_index" value="<%=strDIndex%>">
		<input type="hidden" name="requested_by" value="<%=strReqName%>">
	<%}%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td valign="top">Purpose/Job</td>
      <td colspan="3"> <%if(vReqInfo != null && vReqInfo.size() > 1 && !(WI.fillTextValue("pageReloaded").equals("1")))
	  		strTemp = (String)vReqInfo.elementAt(5);
	    else if(WI.fillTextValue("purpose").length() > 0)
	  		strTemp = WI.fillTextValue("purpose");
		else
			strTemp = "";
	  	%> <textarea name="purpose" cols="40" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Date Needed</td>
      <td colspan="3"> <%if(vReqInfo != null && vReqInfo.size() > 1 && !(WI.fillTextValue("pageReloaded").equals("1")))  	
			strTemp = WI.getStrValue((String)vReqInfo.elementAt(6));
	  	 else if(WI.fillTextValue("date_needed").length() > 0)
	  		strTemp = WI.fillTextValue("date_needed");
		 else
			strTemp = "";
	  %> <input name="date_needed" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_needed');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
	<%if(bolShowPOSign){%>
	<%
		strTemp = WI.fillTextValue("po_signatory");
	%>
    <tr> 
      <td height="30" colspan="4"><div align="center">PURCHASING OFFICER: 
          <select name="po_signatory">
            <option value="">Select purchasing officer</option>
            <%=dbOP.loadCombo("user_table.user_index","FNAME+ ' ' + MNAME + ' ' + LNAME", " from user_table " +
		  " join pur_po_officers on(pur_po_officers.user_index = user_table.user_index)" +
		  " where user_table.is_valid = 1 and  pur_po_officers.is_valid = 1 and sign_type = 0 order by lname", strTemp, false)%> 
          </select>
          <a href='javascript:UpdatePOSignatory()'><img src="../../../images/update.gif" width="60" height="26" border="0" id="compute"></a> 
        </div></td>    
    </tr>
	<%}%>
    <%if(vReqInfo == null){%>
    <tr> 
      <td height="30" colspan="4"><div align="center"><a href="javascript:PageAction(1,0);"><img src="../../../images/save.gif" border="0"></a> 
          <font size="1" >click to save entry</font></div></td>
    </tr>
    <%}else{%>
    <tr> 
      <td width="3%" height="30">&nbsp;</td>
      <td width="12%">&nbsp;</td>
      <td width="85%" colspan="2"> <a href="javascript:PageAction(2,<%=(String)vReqInfo.elementAt(0)%>)"> 
        <img src="../../../images/edit.gif" border="0"></a> <font size="1">click 
        to save changes</font> <a href="javascript:ProceedClicked();"> <img src="../../../images/cancel.gif" border="0"></a> 
        <font size="1">click to cancel edit</font> <a href="javascript:PageAction(0,<%=(String)vReqInfo.elementAt(0)%>)"> 
        <img src="../../../images/delete.gif" border="0"></a> <font size="1">click 
        to delete this requisition</font> </td>
    </tr>
    <%}%>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2"><div align="right"> 
          <%
		  if(vReqItems != null && (vReqInfo != null && vReqInfo.size() > 0)){%>
          <%if (!strSchCode.startsWith("UI")){%>
          <font size="1">Items per page</font> 
          <select name="num_rows">
            <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rows"),"15"));
				for(int i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <%}else{%>
          <input type="hidden" name="num_rows" value="15">
          <%}%>
          <a href="javascript:PrintPage();"> <img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print Requisition Form</font> 
          <%}// end if vReqItems != null%>
        </div></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <%if(vReqItems != null && vReqInfo != null){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">    
	 <tr>
		 <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>LIST 
		 OF REQUESTED ITEMS</strong></font></div></td>
	 </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td class="thinborder" height="25" colspan="8">Requested by : <strong><%=(String)vReqInfo.elementAt(2)%></strong></td>
    </tr>
    <tr>
      <td width="5%" height="25" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="6%" class="thinborder"><div align="center"><strong>QUANTITY</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>ITEM</strong></div></td>
      <td width="23%" class="thinborder"><div align="center"><strong>PARTICULARS/ITEM 
          DESCRIPTION </strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong>SUPPLIER</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="9%" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
    </tr>
    <%for(int iLoop = 2;iLoop < vReqItems.size();iLoop+=9){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=(iLoop+7)/9%></div></td>
      <td class="thinborder"><div align="center"><%=vReqItems.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItems.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItems.elementAt(iLoop+3)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItems.elementAt(iLoop+4)%></div></td>
      <td class="thinborder"><div align="left"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+5),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+6),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right">
	  	<%if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0")){%>
	 		&nbsp;
		<%}else{%>
			<%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%>
		<%}%></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="5" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=vReqItems.elementAt(0)%></strong></div></td>
      <td height="25" colspan="2" class="thinborder"><div align="right"><strong>TOTAL 
          AMOUNT : </strong></div></td>
      <td height="25" class="thinborder"><div align="right"><strong>
	  <%=vReqItems.elementAt(1)%></strong></div></td>
    </tr>
  </table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>    
  </table>
<%}
}else{%>
<input type="hidden" name="is_supply">
<%}%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">   
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="pageAction" value="<%=WI.fillTextValue("pageAction")%>">
  <input type="hidden" name="strIndex" value="<%=WI.fillTextValue("strIndex")%>">
  <!-- all hidden fields go here
  <input type="hidden" name="is_supply" value="<%//=WI.fillTextValue("is_supply")%>">
  -->
  <input type="hidden" name="forwardTo" value="">
  <input type="hidden" name="pageReloaded" value="">
  <input type="hidden" name="printPage" value="">
  <input type="hidden" name="request_stage" value="1">
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
