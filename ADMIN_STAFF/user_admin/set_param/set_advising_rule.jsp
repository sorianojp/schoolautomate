<%@ page language="java" import="utility.*, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	if(WI.fillTextValue("print_pg").length() > 0) {%>
		<jsp:forward page="./set_advising_rule_print.jsp" />
	<%return;}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
function PageAction(strAction, strInfoIndex) {
	document.form_.print_pg.value = '';

	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.print_pg.value = '';

	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.submit();
}
function Cancel() {
	document.form_.print_pg.value = '';

	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.submit();
}
function OpenSearch(strIsStud) {
	var pgLoc = "";
	if(strIsStud == '1') 
		pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	else
		pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage() {
	document.form_.print_pg.value = '';

	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	if(document.form_.del_all.checked)
		document.form_.page_action.value = "5";
	document.form_.submit();
}
function RemoveMod(strInfoIndex, strModIndex) {
	if(!confirm("Do you want to remove message from this module."))
		return;
	
	document.form_.print_pg.value = '';
	
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
	document.form_.module_code_ref.value = strModIndex;
	document.form_.submit();
}
function PrintPg() {
	document.form_.print_pg.value = '1';
	document.form_.submit();
}

function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

</script>
<%
	Vector vEditInfo  = null;
	Vector vRetResult = null;
	
	String strInfoIndex = null;
	String strErrMsg = null;
	String strTemp = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("SYSTEM ADMINISTRATION-SET PARAMETERS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("SYSTEM ADMINISTRATION"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("SYSTEM ADMINISTRATION-Enrollment-Advising Rules".toUpperCase()),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-PAYMENT"),"0"));
			if(iAccessLevel == 0) {
				iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
			}
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administration-Advising Setting","set_advising_rule.jsp");
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

//end of authenticaion code.
	enrollment.SetParameter sParam = new enrollment.SetParameter();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(sParam.operateOnAdvisingRules(dbOP, request, Integer.parseInt(strTemp)) != null )
			strErrMsg = "Operation successful.";
		else
			strErrMsg = sParam.getErrMsg();
	}
	//view all 
	
	if(WI.fillTextValue("sy_from").length() > 0) {
		vRetResult = sParam.operateOnAdvisingRules(dbOP, request, 4);
		if (strErrMsg==null && vRetResult == null)
			strErrMsg = sParam.getErrMsg();
	}
	
%>


<body bgcolor="#D2AE72">
<form name="form_" action="./set_advising_rule.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          ENROLLMENT - ADVISING RULES ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%" class="thinborderNONE">SY-TERM</td>
      <td width="87%">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress="if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
-
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  readonly="yes"> 
- 
<select name="semester" onChange="ReloadPage();">
  <option value="1">1st Sem</option>
  <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
  <option value="2" selected>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}if(strTemp.compareTo("3") ==0){%>
  <option value="3" selected>3rd Sem</option>
  <%}else{%>
  <option value="3">3rd Sem</option>
  <%}if(strTemp.compareTo("0") ==0){%>
  <option value="0" selected>Summer</option>
  <%}else{%>
  <option value="0">Summer</option>
  <%}%>
</select>
		<input type="image" src="../../../images/refresh.gif">	  </td>
    </tr>
<%if(WI.fillTextValue("sy_from").length() > 0) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="thinborderNONE">Student ID</td>
      <td class="thinborderNONE">
<%
strTemp = WI.fillTextValue("stud_id");
%>
        <input name="stud_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="16" onKeyUp="AjaxMapName('1');">
        <font size="1">&nbsp;&nbsp;&nbsp; <a href="javascript:OpenSearch('1');"><img src="../../../images/search.gif" border="0"></a>(Search Student ID)</font>
		
		<label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute; width:400px;"></label>
		</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td class="thinborderNONE"> Setting </td>
      <td class="thinborderNONE">
<%
strTemp = WI.fillTextValue("block_advising");
if(strTemp.length() == 0 || strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>	  
        <input name="block_advising" type="radio" value="1"<%=strErrMsg%>>Block advising 
<%
if(strTemp.equals("0"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>      <input name="block_advising" type="radio" value="0"<%=strErrMsg%>>Allow advising&nbsp;&nbsp;	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="thinborderNONE"> Reason </td>
      <td><textarea name="reason" cols="55" rows="2" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=WI.fillTextValue("reason")%></textarea></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
  	<%if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(0);
	else	
		strTemp = WI.fillTextValue("set_advising_rule");
	%>
      <td class="thinborderNONE"><font size="1">
        <%if(iAccessLevel > 1) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../../images/add.gif" border="0" name="hide_save"></a> Click to add entry
        <%}else{%>
			Not authorized.
      <%}%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td align="center">
	  	<table width="75%" cellpadding="0" cellspacing="0" class="thinborderALL">
			<tr>
				<%strTemp = "";
				if(vRetResult != null && vRetResult.size() > 0) {
					strTemp = WI.getStrValue(vRetResult.remove(1));
					vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
					vRetResult.removeElementAt(0);
				}%>
					
				<td height="25">Current Maximum Allowed outstanding Balance :
					<input type="text" class="textbox" style="font-size:11px;" value="<%=strTemp%>" size="8"
					 name="max_allowed_osbal" onKeyUp="AllowOnlyInteger('form_','max_allowed_osbal');"
					 onBlur="AllowOnlyFloat('form_','max_allowed_osbal');">			 	</td>
			</tr>
			<tr>
				<td height="25" align="center"><font size="1"><a href='javascript:PageAction(5,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a></font></td>
			</tr>
		</table>	  </td>
    </tr>
    <tr>
      <td height="15">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr bgcolor="#EEEEEE">
      <td height="20">&nbsp;</td>
      <td class="thinborderNONE">Search Filter</td>
      <td class="thinborderNONE">Show Max Result 
<%
strTemp = WI.fillTextValue("max_disp");
if(strTemp.equals("25"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>		  <input name="max_disp" type="radio" value="25"<%=strErrMsg%>>25
<%
strTemp = WI.fillTextValue("max_disp");
if(strTemp.equals("50"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>		  <input name="max_disp" type="radio" value="50"<%=strErrMsg%>>50
<%
strTemp = WI.fillTextValue("max_disp");
if(strTemp.equals("75"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>		  <input name="max_disp" type="radio" value="75"<%=strErrMsg%>>75
<%
strTemp = WI.fillTextValue("max_disp");
if(strTemp.equals("100") || request.getParameter("max_disp") == null)
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>		  <input name="max_disp" type="radio" value="100"<%=strErrMsg%>>100	  </td>
    </tr>
    <tr bgcolor="#EEEEEE">
      <td height="20">&nbsp;</td>
      <td class="thinborderNONE">&nbsp;</td>
      <td class="thinborderNONE"> ID Starts With : 
      <input name="user_id_starts" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("user_id_starts")%>" size="16">
      &nbsp;&nbsp;&nbsp;<input name="image" type="image" src="../../../images/refresh.gif" border="1" onClick="document.form_.print_pg.value=''"></td>
    </tr>
    <tr bgcolor="#EEEEEE">
      <td height="20">&nbsp;</td>
      <td class="thinborderNONE">&nbsp;</td>
      <td class="thinborderNONE">
<%
strTemp = WI.fillTextValue("show_blocked");
if(strTemp.length() > 0)
	strTemp = " checked";
else	
	strTemp = "";
%>	  <input name="show_blocked" type="checkbox" value="1"<%=strTemp%>>
Show Only Students Blocked  
<%
strTemp = WI.fillTextValue("show_allowed");
if(strTemp.length() > 0)
	strTemp = " checked";
else	
	strTemp = ""; 
%>      <input name="show_allowed" type="checkbox" value="1"<%=strTemp%>>
Show only Students Allowed</td>
    </tr>
    <tr> 
      <td height="15" colspan="3">&nbsp;</td>
    </tr>
<%}//show only if sy_from infomration is entered.%>	
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {
	String[] astrConvertBlockReason = {"Allowed","Blocked"};%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td align="right" style="font-size:9px;"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>  Print Page&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="20" colspan="8" class="thinborder"> <div align="center"> <strong><font size="2">-: Advising Setting :- </font></strong></div></td>
    </tr>
    <tr bgcolor="#DDDDDD"> 
      <td width="20%" height="20" class="thinborder"> <div align="center"><strong>ID  (Name)</strong></div></td>
      <td width="36%" class="thinborder"> <div align="center"><strong>Reason</strong></div></td>
      <td align="center" class="thinborder" width="6%"><strong>Setting</strong> </td>
      <td width="15%" align="center" class="thinborder"><strong>Created By</strong></td>
      <td width="15%" align="center" class="thinborder"><strong>Create Date</strong></td>
      <td align="center" class="thinborder" width="8%">&nbsp;</td>
    </tr>
    <%
    for (int i = 0; i<vRetResult.size(); i+=8) { %>
    <tr> 
      <td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i+2)%>(<%=(String)vRetResult.elementAt(i+3)%>)</td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder"><%=astrConvertBlockReason[Integer.parseInt((String)vRetResult.elementAt(i + 1))]%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%></td>
      <td class="thinborder"><font size="1"> 
        <% if(iAccessLevel == 2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        Not authorized
        <%}%>
        </font></td>
    </tr>
    <%}//end of for loop.%>
  </table>
<%}//show only if vRetResult is not null%>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    
  </table>
	<input type="hidden" name="print_pg">
	<input type="hidden" name="info_index">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>