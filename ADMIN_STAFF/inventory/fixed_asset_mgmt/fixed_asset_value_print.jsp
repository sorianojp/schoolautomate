<%@ page language="java" import="utility.*, inventory.InvFixedAssetMngt, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Inventory Entry Log</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
</head>
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
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
							"INVENTORY-INVENTORY LOG","fixed_asset_value.jsp");
		
	InvFixedAssetMngt InvFAM = new InvFixedAssetMngt();	
	Vector vRetResult = null;
	Vector vEditInfo = null;
	Vector vEquipment = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
 	String strAssetType = WI.getStrValue(WI.fillTextValue("asset_type"),"0");
 	int iSearch = 0;

	String[] astrAssetTypeName = {"Buildings","Building Improvements","Land","Land Improvements","Equipment"};
	String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
								"September","October","November","December"};
	
	if(!strAssetType.equals("4"))
		vRetResult = InvFAM.getAssetValue(dbOP,request);		
	if(strAssetType.equals("4") || strAssetType.length() == 0)
		vEquipment = InvFAM.operateOnEquipments(dbOP,request, 4);			
		
	if(vRetResult != null || vEquipment != null)
	  iSearch = InvFAM.getSearchCount();	
%>
<body onLoad="javascript:window.print();">
<form name="form_">
  <%if ((vRetResult != null && vRetResult.size() > 0) 
			|| (vEquipment != null && vEquipment.size() > 0)){%>
  <%if(vEquipment != null && vEquipment.size() > 0){%>
	<table width="100%" border="0"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="9" class="thinborderBOTTOMLEFT"><div align="center"><strong>LIST OF 
          EQUIPMENTS ENCODED</strong></div></td>
    </tr>
    <tr> 
      <td width="22%" height="25" align="center" class="thinborderBOTTOMLEFT"><font size="1"><strong>ASSET 
        DESCRIPTION</strong></font></td>
      <td width="13%" align="center" class="thinborderBOTTOMLEFT"><font size="1"><strong>DATE ACQUIRED</strong></font></td>
      <td width="6%" align="center" class="thinborderBOTTOMLEFT"><font size="1"><strong>COST</strong></font></td>
      <td width="7%" align="center" class="thinborderBOTTOMLEFT"><font size="1"><strong>LIFE</strong></font></td>
      <td width="9%" align="center" class="thinborderBOTTOMLEFT"><span class="thinborderBOTTOMLEFT"> <strong><font size="1">SALVAGE VALUE </font></strong></span></td>
      <td width="11%" align="center" class="thinborderBOTTOMLEFT"><span class="thinborderBOTTOMLEFT"><strong><font size="1">YEARLY DEPRECIATION</font></strong></span></td>
      <td width="11%" align="center" class="thinborderBOTTOMLEFT"><span class="thinborderBOTTOMLEFT"><strong><font size="1">NO. OF YEARS DEPRECIATED </font></strong></span></td>
      <td width="12%" align="center" class="thinborderBOTTOMLEFT"><font size="1"><strong>ACCUMULATED DEPRECIATION</strong></font></td>
      <td width="9%" align="center" class="thinborderBOTTOMLEFT"><strong><font size="1">NET BOOK VALUE</font></strong></td>
    </tr>
    <%for(int i = 0;i < vEquipment.size(); i+=22){%>
    <tr> 
      <td height="25" class="thinborderBOTTOMLEFT"><font size="1"><%=WI.getStrValue((String) vEquipment.elementAt(i+16),"")%><%=WI.getStrValue((String) vEquipment.elementAt(i+2),"")%>&nbsp;<%=WI.getStrValue((String)vEquipment.elementAt(i+11),"")%></font></td>
      <% 
		strTemp = (String) vEquipment.elementAt(i + 21);
		if(strTemp == null){
			strTemp =  (String) vEquipment.elementAt(i+4);
		}
		strTemp2 =  (String) vEquipment.elementAt(i+6);
	  %>
      <td class="thinborderBOTTOMLEFT"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
      <td align="right" class="thinborderBOTTOMLEFT"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp2,true),"")%>&nbsp;</font></td>
      <td align="right" class="thinborderBOTTOMLEFT">
        <font size="1"><%=WI.getStrValue((String) vEquipment.elementAt(i+8),"")%></font></td>
      <%
				strTemp = CommonUtil.formatFloat((String) vEquipment.elementAt(i+17),true);
			%>			
      <td align="right" class="thinborderBOTTOMLEFT"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
      <%
				strTemp = CommonUtil.formatFloat((String) vEquipment.elementAt(i+10),true);
			%>			
      <td align="right" class="thinborderBOTTOMLEFT"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>      
      <td align="right" class="thinborderBOTTOMLEFT"><%=(String) vEquipment.elementAt(i+18)%>&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT"><font size="1"><%=CommonUtil.formatFloat((String) vEquipment.elementAt(i+19),true)%>&nbsp;</font></td>
      <td align="right" class="thinborderBOTTOMLEFT"><font size="1"><%=CommonUtil.formatFloat((String) vEquipment.elementAt(i+20),true)%>&nbsp;</font></td>
    </tr>
    <%}%>
  </table>	
	<%}%>	
	<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="9" class="thinborderBOTTOMLEFT"><div align="center"><strong>LIST OF 
          ASSET(S) ENCODED</strong></div></td>
    </tr>
    <tr> 
      <td width="22%" height="25" align="center" class="thinborderBOTTOMLEFT"><font size="1"><strong>ASSET 
        DESCRIPTION</strong></font></td>
      <td width="13%" align="center" class="thinborderBOTTOMLEFT"><font size="1"><strong>DATE 
        ACQUIRED/ IMPROVEMENT</strong></font></td>
      <td width="6%" align="center" class="thinborderBOTTOMLEFT"><font size="1"><strong>COST</strong></font></td>
      <%if(!strAssetType.equals("2")){%>
      <td width="7%" align="center" class="thinborderBOTTOMLEFT"><strong><font size="1">LIFE</font></strong></td>
      <td width="9%" align="center" class="thinborderBOTTOMLEFT"> <strong><font size="1">SALVAGE VALUE </font></strong></td>
      <td width="12%" align="center" class="thinborderBOTTOMLEFT"><strong><font size="1">YEARLY DEPRECIATION</font></strong></td>
      <td width="11%" align="center" class="thinborderBOTTOMLEFT"><strong><font size="1">NO. OF YEARS DEPRECIATED </font></strong></td>
      <td width="11%" align="center" class="thinborderBOTTOMLEFT"><strong><font size="1">ACCUMULATED DEPRECIATION </font></strong></td>      
      <%}%>
      <%if(strAssetType.equals("2") || strAssetType.equals("0")){
					if(strAssetType.equals("2"))
						strTemp = "CURRENT ASSESSED VALUE";
					else
						strTemp = "NET BOOK VALUE";
			%>
      <td width="9%" align="center" class="thinborderBOTTOMLEFT"><strong><font size="1"><%=strTemp%></font></strong></td>
      <%}%>
    </tr>

    <%for(int i = 0;i < vRetResult.size(); i+=25){%>
    <tr> 
      <td height="25" class="thinborderBOTTOMLEFT"><%=WI.getStrValue((String) vRetResult.elementAt(i+1),"")%>&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+2),"")%></td>
      <% 
			if(strAssetType.equals("0")){ // for building
				strTemp =  (String) vRetResult.elementAt(i+5);
				strTemp2 =  (String) vRetResult.elementAt(i+9);
			}else if(strAssetType.equals("1") || strAssetType.equals("3")){ // for improvements
				strTemp =  (String) vRetResult.elementAt(i+6);
				strTemp2 =  (String) vRetResult.elementAt(i+8);
			}else if(strAssetType.equals("2")){// for land
				strTemp = (String) vRetResult.elementAt(i+4);
				strTemp2 = (String) vRetResult.elementAt(i+7);
			}
		%>
      <td class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp2,true),"")%>&nbsp;</td>
      <%if(!strAssetType.equals("2")){%>
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue((String) vRetResult.elementAt(i+11),"")%>&nbsp;</td>
      <%
				strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(i+20),true);
			%>
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
      <%
		  	strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(i+13),true);
		  %>			
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"n/a")%>&nbsp;</td>
      <%
		  	strTemp = (String) vRetResult.elementAt(i+22);
		  %>						
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"n/a")%>&nbsp;</td>
      <%
		  	strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(i+23),true);
		  %>			
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"n/a")%>&nbsp;</td>
      <%}%>
      <%if(strAssetType.equals("2") || strAssetType.equals("0")){%>
      <%
				if(strAssetType.equals("2"))
			  	strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(i+14),true);
				else
					strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(i+24),true);
		  %>			
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
      <%}%>
    </tr>
    <%}%>
  </table>  	
	<%}%>
  <%}// end if vRetResult != null%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>