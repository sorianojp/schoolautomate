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
<style type="text/css">
    TD.NoBorder {
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 11px;
    }	
    TD.BorderBottom {
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	border-bottom: solid #000000 1px;
	font-size: 11px;
    }			
</style>
</head>
<script language="javascript"  src ="../../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../../jscript/date-picker.js" ></script>
<script>
function ProceedClicked(){
	document.form_.proceed.value = "1";
	this.SubmitOnce('form_');
}
function PrintPg(){
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
}

</script>

<body bgcolor="#D2AE72">
<%
	//authenticate user access level	
if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./asset_index_summary_print.jsp" />
<% return;}
	
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
							"INVENTORY-INVENTORY LOG","asset_index_summary.jsp");
		
	InvFixedAssetMngt InvFAM = new InvFixedAssetMngt();	
	String strErrMsg = null;

	Vector vRetResult = null;
	String strTemp  = null;
	
	vRetResult = InvFAM.viewAssetRegister(dbOP,request);	
	int i = 0;
	int iCount = 1;
	double dTemp = 0d;
	String strUserGroup = null;
	String strNewGroup = null;
	boolean bolNewOffice = false;
	int iIncr = 1;
	int iGroup = 1; 
	String strCurYear = null;
	String strLastYear = null;	
	double dLineTotal = 0d;	

	if(vRetResult == null || vRetResult.size() < 2)
		strErrMsg = InvFAM.getErrMsg();
	else{
		strCurYear = (String)vRetResult.elementAt(1);
		strLastYear = (String)vRetResult.elementAt(0);
	}
%>
<form name="form_" action="./asset_index_summary.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          FIXED ASSETS MANAGEMENT - ASSET REGISTER SUMMARY PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:13px; color:#FF0000; font-weight:bold">&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="26">&nbsp;</td>
      <td width="19%">Cut-off Date </td>
      <td width="77%"> <%strTemp = WI.fillTextValue("cut_off_date");%> <input name="cut_off_date" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.cut_off_date');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
      <img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>      </td>
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
      <td height="19" colspan="3" align="right"><font><a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></td>
    </tr>		
  </table>	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td colspan="3" align="center" class="BorderBottom"><font size="1">Acquisition Cost</font></td>
			<td colspan="3" align="center" class="BorderBottom"><font size="1">Accumulated Depreciation</font></td>
			<td colspan="3" align="center" class="BorderBottom"><font size="1">Book Value</font></td>
		  <td align="center">&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td valign="top" class="BorderBottom"><u><font size="1">Prior Years</font></u></td>
			<td valign="top" class="BorderBottom"><u>SY <%=strLastYear%></u></td>
			<td valign="top" class="BorderBottom"><u>SY <%=strCurYear%></u></td>
			<td valign="top" class="BorderBottom"><u><font size="1">Prior Years</font></u></td>
			<td valign="top" class="BorderBottom"><u>SY <%=strLastYear%></u></td>
			<td valign="top" class="BorderBottom"><u>SY <%=strCurYear%></u></td>
			<td valign="top" class="BorderBottom"><u><font size="1">Prior Years</font></u></td>
			<td valign="top" class="BorderBottom"><u>SY <%=strLastYear%></u></td>
			<td valign="top" class="BorderBottom"><u>SY <%=strCurYear%></u></td>
		  <td align="center" class="BorderBottom"><u>Total</u></td>
		</tr>
		<%
		i = 2;
		for(; i < vRetResult.size();iGroup++){
			bolNewOffice = false;
			strUserGroup = (String)vRetResult.elementAt(i+9);
			iIncr = 1;
			dLineTotal = 0d;
		%>
		<tr>
			<%
				strTemp = (String)vRetResult.elementAt(i+12);
			%>			
		  <td colspan="2" class="NoBorder">&nbsp;<%=iGroup%>. <%=strTemp%></td>
		  <td align="right" class="NoBorder">&nbsp;</td>
		  <td align="right" class="NoBorder">&nbsp;</td>
		  <td align="right" class="NoBorder">&nbsp;</td>
		  <td align="right" class="NoBorder">&nbsp;</td>
		  <td align="right" class="NoBorder">&nbsp;</td>
		  <td align="right" class="NoBorder">&nbsp;</td>
		  <td align="right" class="NoBorder">&nbsp;</td>
		  <td align="right" class="NoBorder">&nbsp;</td>
		  <td align="right" class="NoBorder">&nbsp;</td>
	    <td align="right" class="NoBorder">&nbsp;</td>
		</tr>		
		<%for(; i < vRetResult.size(); i +=15, iIncr++){
				if((vRetResult.size() > i+16) &&  !strUserGroup.equals((String)vRetResult.elementAt(i+24))){					
					bolNewOffice = true;
			}
		%>
		<tr>
			<td class="NoBorder">&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+13);				
				if(strTemp == null)
					strTemp = (String)vRetResult.elementAt(i+14);
			%>			
			<td class="NoBorder"><span class="NoBorder"><%=iIncr%>. <%=strTemp%></span></td>
			<%
				strTemp = (String)vRetResult.elementAt(i);
				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				if(dTemp == 0d)
					strTemp = "-";
				else
					strTemp = CommonUtil.formatFloat(strTemp, true);				
			%>
			<td align="right" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+1);
				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				if(dTemp == 0d)
					strTemp = "-";
				else
					strTemp = CommonUtil.formatFloat(strTemp, true);				
			%>			
			<td align="right" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+2);
				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				if(dTemp == 0d)
					strTemp = "-";
				else
					strTemp = CommonUtil.formatFloat(strTemp, true);				
			%>			
			<td align="right" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+3);
				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				if(dTemp == 0d)
					strTemp = "-";
				else
					strTemp = CommonUtil.formatFloat(strTemp, true);				
			%>			
			<td align="right" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+4);
				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				if(dTemp == 0d)
					strTemp = "-";
				else
					strTemp = CommonUtil.formatFloat(strTemp, true);				
			%>			
			<td align="right" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+5);
				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				if(dTemp == 0d)
					strTemp = "-";
				else
					strTemp = CommonUtil.formatFloat(strTemp, true);				
			%>			
			<td align="right" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+6);
				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dLineTotal = dTemp;
				if(dTemp == 0d)
					strTemp = "-";
				else
					strTemp = CommonUtil.formatFloat(strTemp, true);				
			%>			
			<td align="right" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+7);
				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dLineTotal += dTemp;
				if(dTemp == 0d)
					strTemp = "-";
				else
					strTemp = CommonUtil.formatFloat(strTemp, true);				
			%>			
			<td align="right" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+8);
				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dLineTotal += dTemp;
				if(dTemp == 0d)
					strTemp = "-";
				else
					strTemp = CommonUtil.formatFloat(strTemp, true);				
			%>			
			<td align="right" class="NoBorder"><%=strTemp%>&nbsp;</td>
		  <td align="right" class="NoBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%></td>
		</tr>
		<% if(bolNewOffice){
					i = i + 15;
					break;
				}
		}  // inner for loop%>
		<%} // outer for loop%>
	<tr>
			<td width="4%">&nbsp;</td>
			<td width="16%">&nbsp;</td>
			<td width="8%">&nbsp;</td>
			<td width="8%">&nbsp;</td>
			<td width="8%">&nbsp;</td>
			<td width="8%">&nbsp;</td>
			<td width="8%">&nbsp;</td>
			<td width="8%">&nbsp;</td>
			<td width="8%">&nbsp;</td>
			<td width="8%">&nbsp;</td>
			<td width="8%">&nbsp;</td>
		  <td width="8%">&nbsp;</td>
	</tr>
	</table>
	<%}%>
	<!--
  <table width="100%" height="589" border=" 0" cellpadding="0" cellspacing="0" bordercolor="#111111" bgcolor="#FFFFFF" id="AutoNumber1" style="border-collapse: collapse; border-width: 0">
    <tr>
      <td width="58%" height="16" align="center" ></td>
      <td width="58%" height="16" align="center" ></td>
      <td width="58%" height="16" align="center" ><font size="1">Acquisition Cost</font></td>
      <td width="58%" height="16" align="center" ><font size="1">Accumulated Depreciation</font></td>
      <td width="148%" height="16" align="center" ><font size="1">Book Value</font></td>
    </tr>
    <tr>
      <td width="58%" height="19"  align="center">&nbsp;</td>
      <td width="58%" height="19"  align="center">&nbsp;</td>
      <td width="58%" height="19"  align="center"><u><font size="1">Prior Years</font></u></td>
      <td width="58%" height="19"  align="center"><u><font size="1">SY2003-2004</font></u></td>
      <td width="148%" height="19"  align="center"><u><font size="1">Prior Years</font></u></td>
      <td width="148%" height="19"  align="center"><u><font size="1">SY2003-2004</font></u></td>
      <td width="148%" height="19"  align="center"><u><font size="1">Prior Years</font></u></td>
      <td width="148%" height="19"  align="center"><u><font size="1">SY2003-2004</font></u></td>
    </tr>
    <tr>
      <td width="58%" height="19" ><font size="1">I. GENERAL ADMINISTRATION EQUIPMENT</font></td>
      <td width="58%" height="19"  align="center">&nbsp;</td>
      <td width="58%" height="19"  align="center">&nbsp;</td>
      <td width="58%" height="19"  align="center">&nbsp;</td>
      <td width="148%" height="19"  align="center">&nbsp;</td>
      <td width="148%" height="19"  align="center">&nbsp;</td>
      <td width="148%" height="19"  align="center">&nbsp;</td>
    </tr>
    <tr>
      <td width="58%" height="19"  valign="bottom"><blockquote>
          <p><font size="1">A. Board of Trustees</font></p>
      </blockquote></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">684,695.00</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">399,639.64</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">285,055.36</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
    </tr>
    <tr>
      <td width="58%" height="19"  valign="bottom"><blockquote>
          <p><font size="1">B. Office of the President</font></p>
      </blockquote></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">1,214,599.70</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">217,515.00</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">755,675.35</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">438,942.35</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">217,515.00</font></td>
    </tr>
    <tr>
      <td width="58%" height="19"  valign="baseline"><blockquote>
          <blockquote>
            <p><font size="1">B-1 Fund for Equipment</font></p>
          </blockquote>
      </blockquote></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">1,111,818.47</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">744,558.58</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">367,259.89</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
    </tr>
    <tr>
      <td width="58%" height="19"  valign="baseline"><blockquote>
          <blockquote>
            <p><font size="1">B-2 Institutional Development</font></p>
          </blockquote>
      </blockquote></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">126,560.80</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">126,557.80</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">3.00</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
    </tr>
    <tr>
      <td width="58%" height="19"  valign="baseline"><blockquote>
          <blockquote>
            <p><font size="1">B-3 Assistant to the President</font></p>
          </blockquote>
      </blockquote></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">89,790.00</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">47,000.00</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">37,347.33</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">52,442.67</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">47,000.00</font></td>
    </tr>
    <tr>
      <td width="58%" height="19"  valign="baseline"><blockquote>
          <blockquote>
            <p><font size="1">B-4 Advance to P.R.O (Engr. Lim)</font></p>
          </blockquote>
      </blockquote></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">6,267.50</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">2,507.00</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">3,760.50</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
    </tr>
    <tr>
      <td width="58%" height="19"  valign="baseline"><blockquote>
          <p><font size="1">C. Vice President for Administration</font></p>
      </blockquote></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">287,395.00</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">37,780.00</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">231,775.66</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">55,619.34</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">37,780.00</font></td>
    </tr>
    <tr>
      <td width="58%" height="19"  valign="baseline"><blockquote>
          <p><font size="1">D. Vice President for Academic Affairs</font></p>
      </blockquote></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">254,765.25</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">63,300.00</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">233,533.87</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">21,231.38</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">63,300.00</font></td>
    </tr>
    <tr>
      <td width="58%" height="19"  valign="baseline"><blockquote>
          <p><font size="1">E. Vice President for Finance and 
            Enterprises</font></p>
      </blockquote></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">257,762.50</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">81,700.00</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">192,345.17</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">65,417.33</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">81,700.00</font></td>
    </tr>
    <tr>
      <td width="58%" height="19"  valign="baseline"><blockquote>
          <p><font size="1">F. Business Office</font></p>
      </blockquote></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">2,075,407.00</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">409,660.00</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">1,711,710.80</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">363,696.20</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">409,660.00</font></td>
    </tr>
    <tr>
      <td width="58%" height="19"  valign="baseline"><blockquote>
          <p><font size="1">G. Human Resources and Development Office</font></p>
      </blockquote></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">66,800.00</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">54,120.50</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">18,960.00</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">47,840.00</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">54,120.50</font></td>
    </tr>
    <tr>
      <td width="58%" height="19"  valign="baseline"><blockquote>
          <p><font size="1">H. Personnel Officer</font></p>
      </blockquote></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">321,400.00</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">6,500.00</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">236,013.81</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">85,396.19</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">6,500.00</font></td>
    </tr>
    <tr>
      <td width="58%" height="19"  valign="baseline"><blockquote>
          <p><font size="1">I. CPU Computerization</font></p>
      </blockquote></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">2,321,064.25</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">233,585.00</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">1,389,161.86</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">931,902.39</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">233,585.00</font></td>
    </tr>
    <tr>
      <td width="58%" height="19"  valign="baseline"><blockquote>
          <p><font size="1">I-1. Electronic Data Processing</font></p>
      </blockquote></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">639,125.00</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">193.960.00</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">217,514.67</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">421,610.33</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">193,960.00</font></td>
    </tr>
    <tr>
      <td width="58%" height="19"  valign="baseline"><blockquote>
          <p><font size="1">J. Internal Audit</font></p>
      </blockquote></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">61,045.00</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">70,084.00</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">19,428.33</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">41,616.67</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">70,084.00</font></td>
    </tr>
    <tr>
      <td width="58%" height="19"  valign="baseline"><blockquote>
          <p><font size="1">K. Discipline &amp; Safety</font></p>
      </blockquote></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">183,720.00</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">65,400.00</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">87,013.00</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">96,707.00</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">65,400.00</font></td>
    </tr>
    <tr>
      <td width="58%" height="19"  valign="baseline"><blockquote>
          <p><font size="1">L. Purchasing Office</font></p>
      </blockquote></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">6,200.00</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">6,200.00</font></td>
    </tr>
    <tr>
      <td width="58%" height="19"  valign="baseline"><blockquote>
          <p><font size="1">M. Retirement Fund</font></p>
      </blockquote></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">102,475.50</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">87,697.10</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">14,778.40</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
    </tr>
    <tr>
      <td width="58%" height="19"  valign="baseline"><blockquote>
          <p><font size="1">Total General Administration Equipment</font></p>
      </blockquote></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">9,804,700.97</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">1,486,804.50</font></td>
      <td width="58%" height="19"  align="center" valign="top"><font size="1">6,511,421.97</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">3,293,279.00</font></td>
      <td width="148%" height="19"  align="center" valign="top"><font size="1">1,486.804.50</font></td>
    </tr>
    
    <tr>
      <td width="58%" height="19"  colspan="2">&nbsp;</td>
      <td width="58%" height="19"  align="center">&nbsp;</td>
      <td width="58%" height="19"  align="center">&nbsp;</td>
      <td width="148%" height="19"  align="center">&nbsp;</td>
      <td width="148%" height="19"  align="center"><font size="1">-</font></td>
      <td width="148%" height="19"  align="center">&nbsp;</td>
      <td width="148%" height="19"  align="center">&nbsp;</td>
    </tr>
  </table>
	-->
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" >&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="proceed">
	<input type="hidden" name="print_pg">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>