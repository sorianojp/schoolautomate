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
	font-size: 10px;
    }			
		    TD.BorderTop {
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	border-top: solid #000000 1px;
	font-size: 11px;
    }			
</style>
</head>
<script language="javascript"  src ="../../../../jscript/common.js" ></script>
<body onLoad="javascript:window.print();">
<%
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
	double dPriorCost = 0d;
	double dCost1 = 0d;
	double dCost2 = 0d;
	double dPriorDep = 0d;
	double dDep1 = 0d;
	double dDep2 = 0d;
	double dPriorBook = 0d;
	double dBook1 = 0d;
	double dBook2 = 0d;
	double dGroupTotal = 0d;
	String strGroupName = null;
	

	if(vRetResult == null || vRetResult.size() < 2)
		strErrMsg = InvFAM.getErrMsg();
	else{
		strCurYear = (String)vRetResult.elementAt(1);
		strLastYear = (String)vRetResult.elementAt(0);
	}
%>
<form name="form_">
  <%if(vRetResult != null && vRetResult.size() > 0){%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr>
      <td height="18">&nbsp;</td>
      <td><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></div></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    
    <tr>
      <td height="18">&nbsp;</td>
      <td><div align="center"> ASSET REGISTER SUMMARY<br>
      As of <%=WI.fillTextValue("cut_off_date")%></div></td>
      <td>&nbsp;</td>
    </tr>		
    
    <tr>
      <td  width="15%" height="18" valign="bottom">&nbsp;</td>
      <td width="70%" height="18" valign="bottom">&nbsp;</td>
      <td width="15%" height="18" valign="bottom">&nbsp;</td>
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
			<td align="center" valign="top" class="NoBorder"><u><font size="1">Prior Years</font></u></td>
			<td align="center" valign="top" class="NoBorder"><u>SY <%=strLastYear%></u></td>
			<td align="center" valign="top" class="NoBorder"><u>SY <%=strCurYear%></u></td>
			<td align="center" valign="top" class="NoBorder"><u><font size="1">Prior Years</font></u></td>
			<td align="center" valign="top" class="NoBorder"><u>SY <%=strLastYear%></u></td>
			<td align="center" valign="top" class="NoBorder"><u>SY <%=strCurYear%></u></td>
			<td align="center" valign="top" class="NoBorder"><u><font size="1">Prior Years</font></u></td>
			<td align="center" valign="top" class="NoBorder"><u>SY <%=strLastYear%></u></td>
			<td align="center" valign="top" class="NoBorder"><u>SY <%=strCurYear%></u></td>
		  <td align="center" class="NoBorder"><u>Total</u></td>
		</tr>
		<%
		i = 2;
		for(; i < vRetResult.size();iGroup++){
			bolNewOffice = false;
			strUserGroup = (String)vRetResult.elementAt(i+9);
			iIncr = 1;
			dLineTotal = 0d;
			dPriorCost = 0d;
	 	  dPriorCost = 0d;
			dCost1 = 0d;
			dCost2 = 0d;
			dPriorDep = 0d;
			dDep1 = 0d;
			dDep2 = 0d;
			dPriorBook = 0d;
			dBook1 = 0d;
			dBook2 = 0d;			
			dGroupTotal = 0d;
		%>
		<tr>
			<%
				strGroupName = (String)vRetResult.elementAt(i+12);
			%>			
		  <td colspan="2" class="NoBorder">&nbsp;<%=iGroup%>. <%=strGroupName%></td>
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
			<td valign="bottom" class="NoBorder"><span class="NoBorder"><%=iIncr%>. <%=strTemp%></span></td>
			<%
				strTemp = (String)vRetResult.elementAt(i);
				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dPriorCost += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
				else
					strTemp = CommonUtil.formatFloat(strTemp, true);				
			%>
			<td align="right" valign="bottom" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+1);
				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dCost1 += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
				else
					strTemp = CommonUtil.formatFloat(strTemp, true);				
			%>			
			<td align="right" valign="bottom" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+2);
				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dCost2 += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
				else
					strTemp = CommonUtil.formatFloat(strTemp, true);				
			%>			
			<td align="right" valign="bottom" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+3);
				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dPriorDep += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
				else
					strTemp = CommonUtil.formatFloat(strTemp, true);				
			%>			
			<td align="right" valign="bottom" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+4);
				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dDep1 += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
				else
					strTemp = CommonUtil.formatFloat(strTemp, true);				
			%>			
			<td align="right" valign="bottom" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+5);
				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dDep2 += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
				else
					strTemp = CommonUtil.formatFloat(strTemp, true);				
			%>			
			<td align="right" valign="bottom" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+6);
				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dLineTotal = dTemp;
				dPriorBook += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
				else
					strTemp = CommonUtil.formatFloat(strTemp, true);				
			%>			
			<td align="right" valign="bottom" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+7);
				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dLineTotal += dTemp;
				dBook1 += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
				else
					strTemp = CommonUtil.formatFloat(strTemp, true);				
			%>			
			<td align="right" valign="bottom" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+8);
				strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dLineTotal += dTemp;
				dBook2 += dTemp;
				if(dTemp == 0d)
					strTemp = "--";
				else
					strTemp = CommonUtil.formatFloat(strTemp, true);				
			%>			
			<td align="right" valign="bottom" class="NoBorder"><%=strTemp%>&nbsp;</td>
			<%
				dGroupTotal += dLineTotal;
			%>
		  <td align="right" valign="bottom" class="NoBorder"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
		</tr>
		<% if(bolNewOffice){
					i = i + 15;
					break;
				}
		}  // inner for loop%>		
		<tr>
		  <td height="24" colspan="2" class="NoBorder">Total <%=strGroupName%></td>
		  <td align="right" class="BorderTop">&nbsp;<%=CommonUtil.formatFloat(dPriorCost, true)%>&nbsp;</td>
		  <td align="right" class="BorderTop">&nbsp;<%=CommonUtil.formatFloat(dCost1, true)%>&nbsp;</td>
		  <td align="right" class="BorderTop">&nbsp;<%=CommonUtil.formatFloat(dCost2, true)%>&nbsp;</td>
		  <td align="right" class="BorderTop">&nbsp;<%=CommonUtil.formatFloat(dPriorDep, true)%>&nbsp;</td>
		  <td align="right" class="BorderTop">&nbsp;<%=CommonUtil.formatFloat(dDep1, true)%>&nbsp;</td>
		  <td align="right" class="BorderTop">&nbsp;<%=CommonUtil.formatFloat(dDep2, true)%>&nbsp;</td>
		  <td align="right" class="BorderTop">&nbsp;<%=CommonUtil.formatFloat(dPriorBook, true)%>&nbsp;</td>
		  <td align="right" class="BorderTop">&nbsp;<%=CommonUtil.formatFloat(dBook1, true)%>&nbsp;</td>
		  <td align="right" class="BorderTop">&nbsp;<%=CommonUtil.formatFloat(dBook2, true)%>&nbsp;</td>
		  <td align="right" class="BorderTop">&nbsp;<%=CommonUtil.formatFloat(dGroupTotal, true)%>&nbsp;</td>
	  </tr>
		<%} // outer for loop%>
		<tr>
			<td width="2%">&nbsp;</td>
			<td width="21%">&nbsp;</td>
			<td width="7%">&nbsp;</td>
			<td width="8%">&nbsp;</td>
			<td width="8%">&nbsp;</td>
			<td width="7%">&nbsp;</td>
			<td width="8%">&nbsp;</td>
			<td width="8%">&nbsp;</td>
			<td width="7%">&nbsp;</td>
			<td width="8%">&nbsp;</td>
			<td width="8%">&nbsp;</td>
		  <td width="8%">&nbsp;</td>
	</tr>
	</table>
	<%}%>	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>