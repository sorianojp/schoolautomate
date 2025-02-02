<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript">
function AjaxMapName(strPos) {
	var strCompleteName;
	strCompleteName = document.form_.stud_id.value;
	if(strCompleteName.length < 2 )
		return;
	
	var objCOAInput;
	objCOAInput = document.getElementById("coa_info");
		
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_temp=1&search_id=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.page_action.value = '';
	document.form_.proceed.value="1";	
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
function Proceed(){
	document.form_.proceed.value="1";	
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
	if(strinfo.length > 0){
	  	document.form_.info_index.value = strinfo;
	}	
	document.form_.proceed.value="1";  	
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72" onLoad="document.form_.stud_id.focus()">
<%@ page language="java" import="utility.*,enrollment.NAApplicationForm,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar-admission requirement","allow_block_temp_id_advising.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%return;
	}
//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","ADMISSION REQUIREMENTS",request.getRemoteAddr(),
									"allow_block_temp_id_advising.jsp");
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
	Vector vCRStudInfo = null;
	Vector vEditInfo = null;
	Vector vAdStatus =null;
	
	boolean bolAllowEdit = true;
	String strStudCurrentStat = null;
	
	NAApplicationForm NAAppForm = new NAApplicationForm();
	
	String[] astrSemester ={"Summer","First Semester","Second Semester","Third Semester"};
	String[] astrAdvisingStatus ={"Block Advising","Block Online Advising","Allow Online Advising"};
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");	
			
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(NAAppForm.operateOnOnlineAdvisingNew(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = NAAppForm.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Information successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Information successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "Information successfully edited.";			
			strPrepareToEdit = "0";
		}
	}
	 
	if(WI.fillTextValue("stud_id").length()>0){
		vCRStudInfo = NAAppForm.operateOnOnlineAdvisingNew(dbOP,request,5);
		if (vCRStudInfo == null) 
			strErrMsg= NAAppForm.getErrMsg();						
	}
	if(vCRStudInfo!=null && vCRStudInfo.size()>0){
		vAdStatus = NAAppForm.checkOnlineAdvsingStat(dbOP,(String)vCRStudInfo.elementAt(0));
		if(vAdStatus == null) 
			strErrMsg= NAAppForm.getErrMsg();	
		else {
			if(vCRStudInfo.elementAt(11) != null) {
				strStudCurrentStat = "Already Enrolled";
				bolAllowEdit = false;
			}
			else if(vCRStudInfo.elementAt(10) != null) {
				strStudCurrentStat = "Already Advised";
				bolAllowEdit = false;
			}
			else {
				strStudCurrentStat = (String)vAdStatus.elementAt(0);
				strStudCurrentStat = astrAdvisingStatus[Integer.parseInt(strStudCurrentStat)];
			}	
		}
	
		vRetResult = NAAppForm.operateOnOnlineAdvisingNew(dbOP, request,4);
		if(vRetResult == null)
			strErrMsg = NAAppForm.getErrMsg();	
	}				
     if(strPrepareToEdit.equals("1")){
		 vEditInfo = NAAppForm.operateOnOnlineAdvisingNew(dbOP, request,3);
		 if(vEditInfo == null)
			strErrMsg = NAAppForm.getErrMsg();
	 }
%>
<form name="form_" action="./allow_block_temp_id_advising.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: ALLOW BLOCK STUDENT ADVISING ::::</strong></font></div></td>		 
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td width="10%">Student ID:</td>
      <td width="14%">
	  <input name="stud_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("stud_id")%>" size="16"  onKeyUp="AjaxMapName('1');">
	  </td>
	  <td width="6%">&nbsp;</td>
	  <td width="12%"><a href="javascript:Proceed();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
	  <td width="53%">
	  <label id="coa_info" style="font-size:11px; position:absolute; width:300px; font-weight:bold; color:#0000FF"></label></td>
   </tr>
   <tr>
		<td colspan="6"><hr size="1"></td>
	</tr>
  </table>
<%if( vCRStudInfo!=null && WI.fillTextValue("proceed").length()>0){%>
<table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="5%" height="25">&nbsp;</td>
		<td width="18%">Student Name:</td>
	<%	strTemp = WebInterface.formatName((String)vCRStudInfo.elementAt(1),(String)vCRStudInfo.elementAt(2),
					(String)vCRStudInfo.elementAt(3),4);
	%>
		<td colspan="3"><strong><%=strTemp%></strong></td>
	</tr>
	<tr>
		<td width="5%" height="25">&nbsp;</td>
		<td>Course/Major:</td>
		<td colspan="3"><strong><%=(String)vCRStudInfo.elementAt(7)%>
			<%if(vCRStudInfo.elementAt(8) != null){%>
			/<%=(String)vCRStudInfo.elementAt(8)%>
			<%}%></strong></td>
	</tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td>SY-Term</td>
	  <td width="42%"><strong><%=(String)vCRStudInfo.elementAt(4)%> - <%=(String)vCRStudInfo.elementAt(5)%> (<%=astrSemester[Integer.parseInt((String)vCRStudInfo.elementAt(6))]%>)</strong></td>
      <td width="8%">Status</td>
      <td width="27%"><strong><%=(String)vCRStudInfo.elementAt(9)%></strong></td>
	</tr>
<%if(vAdStatus!=null && vAdStatus.size()>0 && WI.fillTextValue("proceed").length()>0){%>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Advising Current Status:</td>
		<td colspan="3" style="font-size:18px; font-weight:bold">
		<strong><%=WI.getStrValue(strStudCurrentStat,"Not Set")%></strong>		</td>
	</tr>
<%}%>
	<tr>
		<td colspan="5"><hr size="1"></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Set Advising Status:</td>
		<td colspan="3">
		<select name="allow_advising">
		  <%strTemp = WI.fillTextValue("allow_advising");
		    if(vEditInfo!=null && vEditInfo.size()>0)
				strTemp = (String) vEditInfo.elementAt(1);
			if(strTemp == null || strTemp.length() == 0) 
				strTemp = "2";
			if(strTemp.equals("0")){%>         		
			<option value="0" selected>Block Advising</option>
          <%}else{%>
		  	<option value="0">Block Advising</option>
		  <%}if(strTemp.equals("1")){%>
		   	<option value="1" selected>Block Online Advising</option>
		  <%}else{%>
		   	<option value="1">Block Online Advising</option>
		  <%}if(strTemp.equals("2")){%>
		    <option value="2" selected>Allow Online Advising</option>
		  <%}else{%>
		   	<option value="2">Allow Online Advising</option>
		  <%}%>
	    </select>		</td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
		<td>Remark:</td>
		<td colspan="3">
		<%  strTemp = WI.fillTextValue("remark");
			if(vEditInfo!=null && vEditInfo.size()>0)
				strTemp = WI.getStrValue((String) vEditInfo.elementAt(2));
		%>
	    <textarea name="remark" cols="45" rows="2" class="textbox"
	    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>	   	</td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td colspan="4">
		<div align="left">
<%if(strPrepareToEdit.equals("0")){%> 
		<a href="javascript:PageAction('1','');">
		<img src="../../../images/save.gif" border="0"></a> <font size="1">click to save entries </font>
<%}else{%>
        <a href="javascript:PageAction('2','');">
		<img src="../../../images/edit.gif" border="0"></a> <font size="1">click to edit entries </font>		
<%}%>	<a href="./allow_block_temp_id_advising.jsp">
	  <img src="../../../images/cancel.gif" border="0" /></a><font size="1">click to cancel/clear entries</font>	  </div></td>
	</tr>
	<tr>
      <td colspan="5">&nbsp;</td>
    </tr>
</table> 
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="4" class="thinborder"><div align="center">LIST OF ADVISNG STATUS SET</div></td>
    </tr>
    <tr style="font-weight:bold" align="center"> 
      <td height="25" width="20%" class="thinborder"><font size="1">Advising Status</font></td>
      <td width="50%" class="thinborder"><font size="1">Remark</font></td>
	  <td width="15%" class="thinborder"><font size="1">Created Date</font></td>
      <td width="15%" class="thinborder"><font size="1">Options</font></td>
    </tr>
    <%for(int i = 0; i<vRetResult.size(); i +=4){%>
    <tr> 
      <td height="25" class="thinborder"><%=astrAdvisingStatus[Integer.parseInt((String)vRetResult.elementAt(i + 1))]%></td>
	  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 2),"&nbsp;")%></td>
	  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 3),"&nbsp;")%></td>
	  <td class="thinborder">
	  <%if(bolAllowEdit) {%>
	  <a href="javascript:PageAction('3','<%=(String)vRetResult.elementAt(i)%>');"> <img src="../../../images/edit.gif" border="0" /></a>&nbsp;&nbsp;
	 <a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">  <img src="../../../images/delete.gif" border="0" /></a>	 
	 <%}%>
	 </td>      
    </tr>
    <%}//end of vRetResult loop%>
  </table>
 <%}//end of vRetResult!=null && vRetResult.size()>0
 }%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
<input type="hidden" name="page_action">
<input type="hidden" name="proceed">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="info_index" value="<%= WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
