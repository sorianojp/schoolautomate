<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="JavaScript" src="../../jscript/common.js"></script>
<!--<script language="JavaScript" src="../../jscript/color_picker/color-picker.js"></script>-->
<script language="JavaScript">
function ReloadPage()
{	
 	this.SubmitOnce('form_');
}

function UpdateRecord(isDefault){
	if(document.form_.module.value == "0"){
		var vProceed = confirm("This would overwrite existing color settings for all modules.Do you want to continue?");
		if(!vProceed){
			return;
		}
	}
	document.form_.is_default.value = isDefault;
	document.form_.reloaded.value = "1";
	document.form_.update.value = "1";
	this.SubmitOnce('form_');
}

/**
var restrict = false;
function CheckKey(objTextName, isOnBlur){
	if(!isOnBlur) 
		restrict = true;
	if(isOnBlur && restrict) {
		restrict = false;
		return;
	}
	//alert(event.keyCode);
	var strTextVal = objTextName.value;
	if(strTextVal.charAt(0) != "#"){
		strTextVal = "#" + strTextVal;
		objTextName.value = strTextVal;
	}
	
	var ilen = strTextVal.length;
	var charat;
	for(var i = 1; i < ilen; i++){
		charat = strTextVal.charAt(i);
		
		if(charat.toUpperCase() == 'A' || charat == 'b' || charat == 'B' || 
		charat == 'c' || charat == 'C' || charat == 'd' || charat == 'D' || 
		charat == 'e' || charat == 'E' || charat == 'f' || charat == 'F')
			continue;
		
		if(isNaN(charat)) {
			alert(charat+" : Is invalid color code.");
			objTextName.focus();
			return;
		}
	}
	
	if(isOnBlur) {
		if(ilen != 7) {
			alert("Color code must be 7 char including #");
			objTextName.focus();
			return;
		}
	}
}
 */
function previewTable(){
	var strLink = document.form_.links_color.value;
	var strBg = document.form_.bg_color.value;
	var strHeader = document.form_.header_color.value;
	
	if(strLink.length != 6 ||  strBg.length != 6 || strHeader.length != 6){
		document.getElementById('td_link').style.backgroundColor = "#FFFFFF";
		document.getElementById('td_bg').style.backgroundColor = "#FFFFFF";
		document.getElementById('td_header').style.backgroundColor = "#FFFFFF";
		document.getElementById('td_footer').style.backgroundColor = "#FFFFFF";
		return;
	}
		document.getElementById('td_link').style.backgroundColor = "#"+strLink;
		document.getElementById('td_bg').style.backgroundColor = "#"+strBg;
		document.getElementById('td_header').style.backgroundColor = "#"+strHeader;
		document.getElementById('td_footer').style.backgroundColor = "#"+strHeader;
}

var newwindow='';
function pickerPopup(ifn, strDefault){
	var bl=screen.width/2-102;
	var bt=screen.height/2-50;
	page="../../jscript/default.jsp?opner_info=form_."+ifn+"&defaultCode="+strDefault;
	if(!newwindow.closed && newwindow.location){
		newwindow.location.href=page;
	}else{
			newwindow=window.open(page,"CTRLWINDOW","help=no,status=no,toolbar=no,menubar=no,location=no,scrollbars=no,resizable=no,dependent=yes,width=550,height=300,left="+bl+",top="+bt+",");
			if(!newwindow.opener)newwindow.opener=self;
	};

	if(window.focus){
		newwindow.focus()
	}
	
}
</script>
</head> 
<body bgcolor="#D2AE72" onFocus="previewTable();" onLoad="previewTable();">
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ColorScheme" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Set Allowed late time in","set_dtr_late_timein.jsp");
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
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(), 
														"set_dtr_late_timein.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}
 
 	String[] astrModule = {"Every where","ADMINISTRATION", "ADMIN/STAFF","FACULTY/ACAD", 
												 "PARENT/STUDENT", "HR", "PAYROLL", "eDTR", "HEALTH MONITORING", 
												 "ESS"};

	ColorScheme	cs = new ColorScheme();
	Vector vRetResult = null;
	if(WI.fillTextValue("update").length() > 0){
		if(cs.operateOnColorScheme(dbOP, request, 2) == null)
			strErrMsg = cs.getErrMsg();
	}
	
	vRetResult = cs.operateOnColorScheme(dbOP, request, 3);
 	
%>	
<form action="./set_color_scheme.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SYSTEM COLOR SCHEME SETTINGS ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Module</td>
      <td height="30">
			<select name="module" onChange="ReloadPage();">
				<%
					strTemp = WI.fillTextValue("module");
				%>
        <option value="0">Everywhere</option>
				<%for(int i = 1; i < 10; i++){%>
				<%if(strTemp.equals(Integer.toString(i))){%>
        <option value="<%=i%>" selected><%=astrModule[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrModule[i]%></option>
        <%}%>
				<%}%>
      </select></td>
      <td height="30" align="right"><a href="javascript:UpdateRecord('1');">Revert selected module to default</a></td>
      <td align="right">&nbsp;</td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td style="font-size:11px; font-weight:bold; color:#993300" valign="bottom"><u>Links Page Color</u></td>
      <td height="30">&nbsp; </td>
      <td width="52%" rowspan="7"><table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" height="150" class="thinborderALL">
        <tr>
          <td width="30%" class="thinborderRIGHT" id="td_link"><strong><font color="#FFFFFF">LINKS</font></strong></td>
          <td align="center" id="td_bg"><table width="90%" border="0" cellpadding="0" cellspacing="0" height="120">
              <tr>
                <td height="18" align="center" id="td_header"><font color="#FFFFFF">PAGE HEADER</font></td>
              </tr>
              <tr>
                <td height="85" bgcolor="#FFFFFF">&nbsp;</td>
              </tr>
              <tr>
                <td id="td_footer">&nbsp;</td>
              </tr>
          </table></td>
        </tr>
      </table>
      <!--			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
        <tr>
          <td width="31%" rowspan="5" id="td_link">LINKS </td>
          <td height="25" id="td_bg">BACKGROUND</td>
        </tr>
        <tr>
          <td height="25" id="td_header">HEADER</td>
        </tr>
        <tr>
          <td width="69%" height="100">&nbsp;</td>
        </tr>
        <tr>
          <td height="26" id="td_footer">FOOTER</td>
        </tr>
        <tr>
          <td height="25" id="td_bg2">&nbsp;</td>
        </tr>
      </table>--></td>
      <td width="3%" rowspan="7">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(0);
				else
					strTemp = "";
			%>			
      <td>Current Color : #<%=strTemp%></td>
			<%
				if(vRetResult != null && vRetResult.size() > 0 && !WI.fillTextValue("reloaded").equals("1"))
					strTemp = (String)vRetResult.elementAt(0);
				else
					strTemp = WI.fillTextValue("links_color");
			%>			
      <td height="25">
			<input type="text" name="links_color" size="10" maxlength="6" 
		  value="<%=WI.getStrValue(strTemp,"")%>" class="textbox"  
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			 onChange="previewTable();" readonly>
			<input type="button" onClick="pickerPopup('links_color','<%=strTemp%>');" value="..."></td>
    </tr>
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="25%" style="font-size:11px; font-weight:bold; color:#993300" valign="bottom"><u>Page Background Color</u></td>
      <td width="19%" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(1);
				else
					strTemp = "";					
			%>			
      <td>Current Color : #<%=strTemp%></td>
			<%
				if(vRetResult != null && vRetResult.size() > 0 && !WI.fillTextValue("reloaded").equals("1"))
					strTemp = (String)vRetResult.elementAt(1);
				else
					strTemp = WI.fillTextValue("bg_color");
			%>			
      <td height="25">
			<input type="text" name="bg_color" size="10" maxlength="7" class="textbox" 
			onfocus="style.backgroundColor='#D3EBFF'"onblur="style.backgroundColor='white'" 
			value="<%=WI.getStrValue(strTemp,"")%>" readonly>
			<input name="button" type="button" onClick="pickerPopup('bg_color','<%=strTemp%>');" value="..."></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-size:11px; font-weight:bold; color:#993300" valign="bottom"><u>Header / Footer Color</u></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
			<%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(2);
				else
					strTemp = "";
			%>			
      <td>Current Color : #<%=strTemp%></td>
			<%
				if(vRetResult != null && vRetResult.size() > 0 && !WI.fillTextValue("reloaded").equals("1"))
					strTemp = (String)vRetResult.elementAt(2);
				else
					strTemp = WI.fillTextValue("header_color");
			%>				
      <td height="30">
			<input type="text" name="header_color" size="10" maxlength="7" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			value="<%=WI.getStrValue(strTemp,"")%>" readonly>
			<input name="button2" type="button" onClick="pickerPopup('header_color','<%=strTemp%>');" value="..."></td>
    </tr>
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="25%">&nbsp;</td>
      <td width="19%" height="25">&nbsp;</td>
    </tr> 
  </table>
	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" colspan="9"><div align="center">
	  <input type="image" src="../../images/save.gif" border="0" onClick="UpdateRecord('0');">
	  <font size="1">click to save changes</font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="update">
	<input type="hidden" name="reloaded">
	<input type="hidden" name="is_default">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>