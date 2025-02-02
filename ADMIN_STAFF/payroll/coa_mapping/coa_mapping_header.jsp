<%@ page language="java" import="utility.*,java.util.Vector, payroll.PRCOAMapping" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>COA Mapping Header Name</title>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function SaveRecord(){
	document.form_.page_action.value = "1";
	document.form_.donot_call_close_wnd.value = "1";
	this.SubmitOnce('form_');	
}

function EditRecord(){
	document.form_.page_action.value = 2;
	document.form_.print_pg.value = "";
	document.form_.donot_call_close_wnd.value = "1";
	this.SubmitOnce('form_');	
}

function DeleteRecord(strInfoIndex) {
	if(!confirm("Continue with delete?"))
		return;
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = 0;
	document.form_.donot_call_close_wnd.value = "1";
	this.SubmitOnce('form_');
}
function CancelRecord() 
{
	document.form_.donot_call_close_wnd.value = "1";
	location = "./coa_mapping_header.jsp";
}
function PrintPg(){
	document.form_.print_pg.value = 1;
	document.form_.donot_call_close_wnd.value = "1";
	this.SubmitOnce('form_');
}

function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.print_pg.value = "";
	document.form_.donot_call_close_wnd.value = "1";
	this.SubmitOnce('form_');
}

function CloseWindow(){
	document.form_.close_wnd_called.value = "1";
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
	window.opener.focus();
	self.close();
}

function ReloadParentWnd() {
	if(document.form_.donot_call_close_wnd.value.length > 0)
		return;

	if(document.form_.close_wnd_called.value == "0") {
		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
		window.opener.focus();
	}
}
 
</script>
</head>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
 		
//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Slip main","coa_mapping_header.jsp");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"PAYROLL","DTR",request.getRemoteAddr(),
														"confidential_setting.jsp");
	
/*															
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
*/

//end of authenticaion code.
	PRCOAMapping prCOA = new PRCOAMapping();	
	Vector vRetResult = null;
	Vector vEditInfo = null;
	int iSearchResult  = 0;
	String strPageAction = WI.fillTextValue("page_action");
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");	
	if(strPageAction.length() > 0){
		vRetResult = prCOA.operateOnHeaderMapping(dbOP, request, Integer.parseInt(strPageAction));
		if(vRetResult == null)
			strErrMsg = prCOA.getErrMsg();
		
		strPrepareToEdit = "0"; 
 	}	
	
	if(strPrepareToEdit.compareTo("1") == 0)
		vEditInfo = prCOA.operateOnHeaderMapping(dbOP, request, 3);	
	
	vRetResult = prCOA.operateOnHeaderMapping(dbOP,request,4);
 	if(vRetResult == null){
		strErrMsg = prCOA.getErrMsg();
	} 
 %>
<body bgcolor="#D88B33" topmargin="0" onUnload="ReloadParentWnd();">
<form name="form_" method="post" action="./coa_mapping_header.jsp">
<table width="100%" border="0">
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>

<table width="100%" border="0" cellpadding="1" cellspacing="1" bgcolor="#A9B9D1">
  
  <tr>
    <td height="17" colspan="3" valign="top">&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    <td width="10%" align="right" valign="top"><a href="javascript:CloseWindow();"><strong><u>CLOSE</u></strong></a></td>
  </tr>
  
  <tr>
    <td width="3%">&nbsp;</td>
    <td width="17%" height="25"><b><font color="#000066">Header Name</font></b></td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(1);
			else
				strTemp = WI.fillTextValue("header_name");
		%>
    <td height="25" colspan="2"><input name="header_name" type="text" size="32"  maxlength="32" value="<%=strTemp%>" 
			class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"/></td>
    </tr>
  
  <tr>
    <td>&nbsp;</td>
    <td height="25"><b><font color="#000066">Order number</font></b></td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(2);
			else
				strTemp = WI.fillTextValue("order_no");
		%>		
    <td height="25" colspan="2"><input type="text" name="order_no" size="4" value="<%=WI.getStrValue(strTemp,"")%>" 
		class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" maxlength="4"/></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td height="22">&nbsp;</td>
    <td height="22" colspan="2">&nbsp; </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td height="22">&nbsp;</td> 
    <td height="22" colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25" colspan="2"><label><font size="1" color="#000066">
      <%if(strPrepareToEdit.equals("1")){%>
      <input type="button" name="edit" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onclick="javascript:EditRecord();" />
click to SAVE entries
<%}else{%>
<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onclick="javascript:SaveRecord();" />
click to SAVE entries
<%}%>
<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onclick="javascript:CancelRecord();" />
click to CANCEL entries</font></label></td>
    </tr>
	</table>
		<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#A9B9D1">
		<tr>
			<td height="21" colspan="2">&nbsp;</td>
		</tr>
	</table>	
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="8%" height="25" align="center" bgcolor="#D3D3D3" class="thinborderTOPLEFTBOTTOM"><font color="#003399"><b>COUNT</b></font></td>
        <td width="57%" height="25" align="center" bgcolor="#D3D3D3"  class="thinborderTOPLEFTBOTTOM"><strong><font color="#003399">HEADER NAME </font></strong></td>
        <td width="15%" align="center" bgcolor="#D3D3D3" class="thinborderALL"><font color="#003399"><b>ORDER # </b></font></td>
        <td width="20%" height="25" align="center" bgcolor="#D3D3D3" class="thinborderALL"><font color="#003399"><b>OPTION</b></font></td>
      </tr>
      <%
			int iCount = 1;
			for(int i = 0; i < vRetResult.size(); i+=6, iCount++){%>
			<tr>
        <td height="20" align="center" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT"><font color="#003399"><%=iCount%></font></td>
        <td height="20" bgcolor="#D3D3D3"  class="thinborderBOTTOMLEFT">&nbsp;<font color="#003399"><%=(String)vRetResult.elementAt(i+1)%></font></td>
				<%
					strTemp = (String)vRetResult.elementAt(i+2);
				%>
        <td align="center" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFTRIGHT"><font color="#003399"><%=strTemp%></font></td>
        <td height="20" align="center" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFTRIGHT">
          <input type="button" name="cancel222" value="  Edit  " style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
					onclick="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');" />
        <input type="button" name="cancel22" value="Delete" style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
					onclick="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>');" />
				</td>
      </tr>
			<%}%>
  </table>	
  <table width="100%" border="0" bgcolor="#A9B9D1">
  <tr>
    <td height="23">&nbsp;</td>
  </tr>
</table>
<%}%>
	<input type="hidden" name="page_action">  
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="print_pg" value=""> 
	
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>">
  	
	<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
	<!-- this is very important - onUnload do not call close window -->
	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>