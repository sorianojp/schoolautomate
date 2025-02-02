<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">

function PrepareToEdit(strIndex, strProvName, strMunicipality, strDistrict ){
	document.form_.prepareToEdit.value = "1";
	document.form_.province_index.value = strIndex;
	document.form_.municipality.value = strMunicipality
	document.form_.district.value = strDistrict;
	document.form_.old_province.value = strIndex;
	document.form_.old_municipality.value = strMunicipality;
	document.form_.old_district.value = strDistrict;
	document.form_.submit();
}
function AddRecord()
{
	document.form_.page_action.value="1";
}

function EditRecord()
{
	document.form_.page_action.value="2";
}

function CancelEdit(){
	location = "./preload_district.jsp";
	
}

function ReloadPage(){
	document.form_.page_action.value = "";
	document.form_.submit();
}

function CloseWindow()
{
	window.opener.document.form_.submit()
	window.opener.focus();
	self.close();
}
</script>

<%@ page language="java" import="utility.*,java.util.Vector,enrollment.ReportEnrollment" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Reports",
								"preload_district.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","Reports",request.getRemoteAddr(), 
														"preload_district.jsp");	
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

	ReportEnrollment re = new ReportEnrollment();
	
	String strPageAction = WI.fillTextValue("page_action");
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	
	if (strPageAction.length() > 0){
	
		if (strPageAction.compareTo("1") == 0){
			vRetResult = re.operateOnDistricts(dbOP,request,1);
			if (vRetResult == null){
				strErrMsg = re.getErrMsg();
			}else{
				strErrMsg = " District added succesfully";
			}
		} else if (strPageAction.compareTo("2") == 0){
			vRetResult = re.operateOnDistricts(dbOP,request,2);
			if (vRetResult == null){
				strErrMsg = re.getErrMsg();
			}else{
				strErrMsg = " District edited succesfully";
			}
		}
	}
	

%>
<body bgcolor="#D2AE72">
<form action="./preload_district.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          DISTRICT MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="4" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="1%">&nbsp;</td>
<% 
	
%>
      <td width="99%" valign="middle"><p>PROVINCE :<br>
          <select name="province_index" onChange="ReloadPage()">
            <option value="" selected> SELECT PROVINCE</option>
            <%=dbOP.loadCombo("PROVIENCE_INDEX","PROVIENCE_NAME"," from PRELOAD_PROVIENCE order by PROVIENCE_NAME",WI.fillTextValue("province_index"), false)%> 
          </select>
          <br>
          <br>
          MUNICIPALITY/ CITY:<br>
          <input name="municipality" id="municipality" value="<%=WI.fillTextValue("municipality")%>" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="64">
          <br>
          <br>
          DISTRICT<br>
          <input name="district" type= "text" class="textbox" id="district"  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("district")%>" size="3" maxlength="3" >
        </p>
        </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td> 
        <% if (strPrepareToEdit.compareTo("1") == 0){%>
        <input name="image" type="image" onClick='EditRecord()' src="../../../images/edit.gif" border="0"> 
        <font size="1">click to save changes</font> <a href='javascript:CancelEdit();'><img src="../../../images/cancel.gif" width="51" height="26" border="0"></a><font size="1">click 
        to cancel edit</font> 
        <%}else{%>
        <input name="image" type="image" onClick='AddRecord()' src="../../../images/add.gif" width="42" height="32"> 
        <font size="1">click to add entry</font> 
        <%}%>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="old_province" value="<%=WI.fillTextValue("old_province")%>">
<input type="hidden" name="old_municipality"  value="<%=WI.fillTextValue("old_municipality")%>">
<input type="hidden" name="old_district"  value="<%=WI.fillTextValue("old_district")%>">


 <% 
 	vRetResult = re.operateOnDistricts(dbOP,request,4);
 	if (vRetResult !=null && vRetResult.size() > 0){ 
 %>  
  <table width="100%" border="0" align="center" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td colspan="6"><div align="center"><strong><font color="#FFFFFF">LIST 
          OF DISTRICTS </font></strong></div></td>
    </tr>
    <tr align="center"> 
      <td width="2%"><font size="1">&nbsp;</font></td>
      <td width="33%"><strong><font size="1">PROVINCE</font></strong></td>
      <td width="34%"><font size="1"><strong>MUNICIPALITY</strong></font></td>
      <td width="18%"><font size="1"><strong>DISTRICT</strong></font></td>
      <td width="11%">&nbsp;</td>
      <td width="2%">&nbsp;</td>
    </tr>
    <% for (int i =0; i < vRetResult.size() ; i+=4){ %>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td>&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
      <td>&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
      <td><div align="center"> <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>",
	  "<%=(String)vRetResult.elementAt(i+1)%>",
	  "<%=(String)vRetResult.elementAt(i+2)%>",
	  "<%=(String)vRetResult.elementAt(i+3)%>");'> 
          <img src="../../../images/edit.gif" width="40" height="26" border="0"></a> 
        </div></td>
      <td>&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
      </tr>
  </table>
  <input type="hidden" name="page_action" value ="">
  <input type="hidden" name="prepareToEdit">
</form>
</body>
</html>

