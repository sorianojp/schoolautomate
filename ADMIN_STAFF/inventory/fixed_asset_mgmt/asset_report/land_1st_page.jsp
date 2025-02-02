<%@ page language="java" import="utility.*, inventory.InvFixedAssetMngt, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Fixed Asset Management - LAND</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../../jscript/date-picker.js" ></script>
<script>

function printPg(strCutOff,strAddDateFr,strAddDateTo){
	var pgLoc = "./land_and_improvements_print.jsp?cut_off_date="+strCutOff+"&date_fr="+strAddDateFr+"&date_to="+strAddDateTo;
	var win=window.open(pgLoc,"PrintWindow",'width=650,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ProceedClicked(){
	document.form_.proceed.value = "1";
	this.SubmitOnce('form_');
}
</script>

<body bgcolor="#D2AE72">
<%
	if (WI.fillTextValue("print_pg").length() > 0){%>
		<jsp:forward page="./inv_entry_log_print.jsp" />
	<% return;}
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-FIXED_ASSET"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("EXECUTIVE MANAGEMENT SYSTEM"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
							"INVENTORY-INVENTORY LOG","land_1st_page.jsp");
		
	InvFixedAssetMngt InvFAM = new InvFixedAssetMngt();	
	String strErrMsg = null;

	Vector vRetResult = null;
	Vector vLands = null;
	Vector vImprovements = null;
	Vector vAdditional = null;
	String strTemp  = null;
	
	vRetResult = InvFAM.searchLandAndImprove(dbOP,request);	
	int i = 0;
	int iCount = 1;

	if(vRetResult != null && vRetResult.size() > 0){
		vLands = (Vector) vRetResult.elementAt(0);
		vImprovements = (Vector) vRetResult.elementAt(1);
		vAdditional = (Vector) vRetResult.elementAt(2);	
	}else
		strErrMsg = InvFAM.getErrMsg();
	
	
%>
<form name="form_" action="./land_1st_page.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          FIXED ASSETS MANAGEMENT - LAND AND LAND IMPROVEMENTS REPORT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:13px; color:#FF0000; font-weight:bold">&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Cut-off Date </td>
      <td> <%strTemp = WI.fillTextValue("cut_off_date");%> <input name="cut_off_date" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.cut_off_date');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td width="4%" height="26">&nbsp;</td>
      <td width="19%">Addition Date Range</td>
      <td width="77%"> <%strTemp = WI.fillTextValue("date_fr");%> <input name="date_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <%strTemp = WI.fillTextValue("date_to");%> <input name="date_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
      </td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td><font size="1"><a href="javascript:ProceedClicked();"><img src="../../../../images/form_proceed.gif" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="19" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%">&nbsp;</td>
      <td height="18" colspan="4"><strong><font size="2">A. LAND</font></strong></td>
    </tr>
	<%if(vLands != null && vLands.size() > 0){%>	
	<%
	for(i = 0;i<vLands.size();i +=4,iCount++){%>
    <tr> 
      <td>&nbsp;</td>
      <td width="7%" height="18"><%=iCount%></td>
      <td width="48%" height="18">&nbsp; <%=(String)vLands.elementAt(i+1)%></td>
	  <%
	  	strTemp = (String)vLands.elementAt(i+2);
	  %>
      <td width="23%"><div align="right">&nbsp;<%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"")%>&nbsp;</div></td>
	  <%
	  	strTemp = (String)vLands.elementAt(i+3);
	  %>	  
      <td width="18%"><div align="right">
	  <%if(false){%>
	  <%=CommonUtil.formatFloat(strTemp,true)%>
	  <%}%>
	  &nbsp;	  
	  </div></td>
    </tr>
	<%}// end for loop%>
	<%}// end if vLands != null%> 
  </table>    
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <%if(vImprovements != null && vImprovements.size() > 0){%>	
    <tr> 
      <td width="4%">&nbsp;</td>
      <td height="18" colspan="4"><strong><font size="2">B. LAND IMPROVEMENTS</font></strong></td>
    </tr>
	<%iCount =1;
	for(i = 0;i<vImprovements.size();i +=6,iCount++){%>
    <tr> 
      <td>&nbsp;</td>
      <td width="7%" height="18"><%=iCount%></td>
      <td width="48%" height="18">&nbsp; <%=(String)vImprovements.elementAt(i+1)%></td>
	  <%
	  	strTemp = (String)vImprovements.elementAt(i+2);
	  %>
      <td width="23%"><div align="right">&nbsp;<%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</div></td>
	  <%
	  	strTemp = (String)vImprovements.elementAt(i+3);
	  %>
      <td width="18%"><div align="right">
	  <%if(false){%>
	  <%=CommonUtil.formatFloat(strTemp,true)%>
	  <%}%>
	  &nbsp;</div></td>
    </tr>
	<%}// end for loop%>
	<%}%>  
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%if(WI.fillTextValue("date_fr").length() > 0 && WI.fillTextValue("date_to").length() > 0){%>
	<tr> 
      <td width="4%">&nbsp;</td>	  
      <td height="18" colspan="4"><strong><font size="2">C. ADD: <%=WI.formatDate(WI.fillTextValue("date_fr"),6)%> 
        - <%=WI.formatDate(WI.fillTextValue("date_to"),6)%> LAND ADDITIONS</font></strong></td>
    </tr>
	
	<%iCount =1;
	for(i = 0;i<vAdditional.size();i +=6,iCount++){%>
    <tr> 
      <td>&nbsp;</td>
      <td width="7%" height="18"><%=iCount%></td>
      <td width="48%" height="18">&nbsp; <%=(String)vAdditional.elementAt(i+1)%></td>
	  <%
	  	strTemp = (String)vAdditional.elementAt(i+2);
	  %>
      <td width="23%"><div align="right">&nbsp;<%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</div></td>
	  <%
	  	strTemp = (String)vAdditional.elementAt(i+3);
	  %>
      <td width="18%"><div align="right">
	  <%if(false){%>
	  <%=CommonUtil.formatFloat(strTemp,true)%>
	  <%}%>
	  &nbsp;</div></td>
    </tr>
	<%}// end for loop%>
	<%}// end checking if date_fr && date_to is not null> 0%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="96%" height="25"><font size="1">&nbsp; <a href="javascript:printPg('<%=WI.fillTextValue("cut_off_date")%>',
									'<%=WI.fillTextValue("date_fr")%>',
									'<%=WI.fillTextValue("date_to")%>');"> 
		<img src="../../../../images/print.gif" width="58" height="26" border="0"></a> 
        click to print list</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <%}// end if vRetResult != null%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="proceed">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>