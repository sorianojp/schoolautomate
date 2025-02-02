<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Inventory Entry Log</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script>
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
function SearchProperty(){
	var pgLoc = "../comp_log/search_component.jsp?opner_info=form_.prop_num&is_component=0";
	var win=window.open(pgLoc,"SearchProperty",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
</head>
<%@ page language="java" import="utility.*,java.util.Vector, inventory.InventoryLog, 
								inventory.InvCPUMaintenance " buffer="16kb"%>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Inventory-Inventory comp","comp_reports_property_card.jsp");
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
														"INVENTORY","COMP_INV",request.getRemoteAddr(),
														"comp_reports_property_card.jsp");
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

	Vector vItemInfo =  null;
	Vector vCPUParts = null;
	Vector vMaintRecord = null;
	
	String strType = null;
	String strPageAction = null;
	String strTemp2 = null;	
	String[] astrAttachType = {"External","Built in"};
	String[] astrUnitMeasure = {"","inches", "Mb", "Gb", "Mhz", "Ghz"};

	InventoryLog InvLog = new InventoryLog();
	InvCPUMaintenance InvMaint = new InvCPUMaintenance();
	
	strPageAction = WI.fillTextValue("page_action");
	if (WI.fillTextValue("prop_num").length() > 0){
	   vItemInfo = InvLog.operateOnComponentsInv(dbOP,request,3);
     if(vItemInfo != null && vItemInfo.size() > 0 ){
		 vCPUParts = InvLog.operateOnComponentsInv(dbOP, request,5);
		 
		 vMaintRecord = InvMaint.getMaintenanceRecord(dbOP,request);
			 if(vCPUParts == null || vCPUParts.size() == 0){
				 strErrMsg =  InvLog.getErrMsg();
				//strErrMsg = "No registered conponents found in the CPU";
			 }
	   }else{
	     strErrMsg = InvLog.getErrMsg();//"Property number not found";		  
	   }
    }
/*
	if (strTemp2.length() > 0) {
	//		 if(InvLog.operateOnComputerInv(dbOP, request, Integer.parseInt(strPageAction)) == null ){
			 if(false){
				strErrMsg = InvLog.getErrMsg();
			 }else{				
				if(strPageAction.equals("1"))
				   strErrMsg = "Computer Log successful.";	

				if(strPageAction.equals("2"))
				   strErrMsg = "Computer Log successfully edited.";
				
				//vCPUParts = InvLog.operateOnComponentsInv(dbOP, request,5);	
			 }
	    } // else // if (strTemp2.equals("1"))
	}//if (strTemp2.length() > 0)
*/
%>

<body bgcolor="#D2AE72">
<form name="form_" action="comp_reports_property_card.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY - CPU PROPERTY CARD PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4"><font size="3"><strong><%=WI.getStrValue(strErrMsg,"&nbsp;")%></strong></font></td>
    </tr>
    <tr> 
      <td width="2%" height="30">&nbsp;</td>
      <td width="17%">Property Number</td>
      <td width="24%" height="30" valign="middle"><font size="1"> 
        <%
	    if(WI.fillTextValue("prop_num").length() > 0)
	  		strTemp = WI.fillTextValue("prop_num");
	  	else
			strTemp = "";
	  %>
        <input name="prop_num" type="text" class="textbox" size="16" maxlength="16" value="<%=strTemp%>">
        <strong><a href="javascript:SearchProperty();"><img src="../../../images/search.gif" alt="search" border="0"></a></strong> 
        </font></td>
      <td width="57%" height="30" valign="middle"><font size="1"><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
  </table>
  <%if (vItemInfo != null && vItemInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
  <%
	  strTemp = (String) vItemInfo.elementAt(0);
  %>
  <input type="hidden" name="computer_index" value="<%=strTemp%>">
    <tr bgcolor="#C78D8D"> 
      <td width="2%" height="26">&nbsp;</td>
      <td colspan="5" bgcolor="#C78D8D"><strong><font color="#FFFFFF">PROPERTY 
        DETAILS</font></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="5"><u><strong>PROPERTY DESCRIPTION</strong></u></td>
    </tr>
    <tr> 
      <td width="2%" height="26">&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <td width="17%">Property Number </td>
      <td width="34%">: 
        <% if (vItemInfo != null && vItemInfo.size() > 0)
	  		strTemp = (String) vItemInfo.elementAt(9);
	  %>
        <strong><%=WI.getStrValue(strTemp,"")%></strong></td>
      <td width="15%">Warranty Until</td>
      <td width="30%">: 
        <% if (vItemInfo != null && vItemInfo.size() > 0)
	  		strTemp = (String) vItemInfo.elementAt(13);
	  %>
        <strong><%=WI.getStrValue(strTemp,"")%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td width="17%">Product Number </td>
      <td width="34%">: 
        <% if (vItemInfo != null && vItemInfo.size() > 0)
	  		strTemp = (String) vItemInfo.elementAt(11);
	  %>
        <strong><%=WI.getStrValue(strTemp,"")%></strong></td>
      <td>Serial Number</td>
      <td>: 
        <% if (vItemInfo != null && vItemInfo.size() > 0)
	  		strTemp = (String) vItemInfo.elementAt(10);
	  %>
        <strong><%=WI.getStrValue(strTemp,"")%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4">Description : 
        <% if (vItemInfo != null && vItemInfo.size() > 0)
	  		strTemp = (String) vItemInfo.elementAt(23);
	  %>
        <strong><%=WI.getStrValue(strTemp,"")%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="5"><u>LOCATION</u></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <td colspan="4"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> : 
      <% if (vItemInfo != null && vItemInfo.size() > 0)
	  		strTemp = (String) vItemInfo.elementAt(23);
	  %>
        <strong><%=WI.getStrValue(strTemp,"")%></strong></td>
    </tr>
    <% if(strTemp != null && strTemp.compareTo("0") != 0 && strTemp.length() > 0){%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4">Department : 
        <% if (vItemInfo != null && vItemInfo.size() > 0)
	  		strTemp = (String) vItemInfo.elementAt(24);
	  %>
        <strong><%=WI.getStrValue(strTemp,"")%></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4">Office : 
        <% if (vItemInfo != null && vItemInfo.size() > 0)
	  		strTemp = (String) vItemInfo.elementAt(24);
	  %>
      <strong><%=WI.getStrValue(strTemp,"")%></strong></td>
    </tr>
    <%}%>
	<tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4">Laboratory/Stock Room : 
        <% if (vItemInfo != null && vItemInfo.size() > 0)
	  		strTemp = (String) vItemInfo.elementAt(26);
	  %>
        <strong><%=WI.getStrValue(strTemp,"")%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4">Building : 
        <% if (vItemInfo != null && vItemInfo.size() > 0)
	  		strTemp = (String) vItemInfo.elementAt(25);
	  %>
        <strong><%=WI.getStrValue(strTemp,"")%></strong></td>
    </tr>
  </table>
  <%
  if (vCPUParts != null && vCPUParts.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3"><table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
          <tr bgcolor="#C78D8D"> 
            <td height="25" colspan="7" class="thinborder"><div align="center"> 
                <strong><font size="2"> PROPERTY CARD FOR PROPERTY NO : 
                  <% if (vItemInfo != null && vItemInfo.size() > 0)
	  		      strTemp = (String) vItemInfo.elementAt(10);	  %>
                  <%=WI.getStrValue(strTemp,"")%></font></strong>
              </div></td>
          </tr>
          <tr bordercolor="#111111"> 
            <td width="201" align="center" class="thinborder"><strong>Component</strong></td>
            <td width="196" align="center" class="thinborder"><strong>Attachment</strong></td>
            <td width="186" align="center" class="thinborder"><strong>Serial Number 
              </strong></td>
            <td width="206" align="center" class="thinborder"><strong>Product 
              Number</strong></td>
            <td width="167" align="center" class="thinborder"><strong>Status</strong></td>
            <td width="127" align="center" class="thinborder"><strong>Warranty</strong></td>
            <td align="center" class="thinborder"><strong>Last Date Updated</strong></td>
          </tr>
          <%for (int i = 0;i < vCPUParts.size(); i+=31){%>
		  <tr bordercolor="#111111"> 
            <td  height="19" class="thinborder"><font size="1">&nbsp;&nbsp;<%=((String)vCPUParts.elementAt(i+20))%></font></td>
            <td valign="middle" class="thinborder"><div align="center">
                <div align="left"><font size="1">&nbsp;&nbsp;<%=(astrAttachType[Integer.parseInt((String)vCPUParts.elementAt(i+14))])%></font></div>
              </div></td>
            <td align="center" class="thinborder"><div align="left"><font size="1">&nbsp;&nbsp;<%=WI.getStrValue((String)vCPUParts.elementAt(i+10),"&nbsp;")%></font></div></td>
            <td align="center" class="thinborder"><div align="left"><font size="1">&nbsp;&nbsp;<%=WI.getStrValue((String)vCPUParts.elementAt(i+11),"&nbsp;")%></font></div></td>
            <td valign="middle" class="thinborder"><div align="left"><font size="1">&nbsp;&nbsp;<%=((String)vCPUParts.elementAt(i+22))%></font></div></td>
						<%
							strTemp = (String)vCPUParts.elementAt(i+13);
						%>
            <td align="center" class="thinborder"><div align="left"><font size="1">&nbsp;&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></font></div></td>
            <td align="center" class="thinborder">&nbsp;</td>
          </tr>
		  <%}%>
          <tr bordercolor="#111111"> 
            <td colspan="7" align="center" class="thinborder">&nbsp;</td>
          </tr>
        </table>
		<%}// end if vCPUParts != null%>
		<%}// end if vItemInfo != null %>
		<%if (vMaintRecord != null && vMaintRecord.size() > 0){%>
        <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr bgcolor="#C78D8D"> 
            <td height="24" colspan="6" align="center" class="thinborder"><strong>MAINTENANCE 
              RECORD </strong></td>
          </tr>
          <tr bordercolor="#111111"> 
            <td width="15%" align="center" class="thinborder"><strong>DATE</strong></td>
            <td colspan="3" align="center" class="thinborder"><strong>ACTION TAKEN 
              </strong></td>
            <td width="23%" colspan="2" align="center" class="thinborder"><strong>UPDATED/PERFORMED 
              BY </strong></td>
          </tr>
          <%for(int i = 0;i < vMaintRecord.size();i+=9){%>
          <tr bordercolor="#111111"> 
            <td align="center" height="19" class="thinborder"><font size="1">&nbsp;&nbsp;<%=((String)vMaintRecord.elementAt(i+4))%></font></td>
            <td colspan="3" align="center" class="thinborder"><div align="left"><font size="1"> 
                <%
				strTemp = WI.getStrValue((String)vMaintRecord.elementAt(i+2),"");
			%>
                <%if (strTemp.equals("0")){%>
                Removed <%=((String)vMaintRecord.elementAt(i+5))%> (<%=((String)vMaintRecord.elementAt(i+7))%>) 
                <%}else if(strTemp.equals("1")){%>
                Installed <%=((String)vMaintRecord.elementAt(i+5))%> (<%=((String)vMaintRecord.elementAt(i+7))%>) 
                <%}else if(strTemp.equals("2")){%>
                Replaced <%=((String)vMaintRecord.elementAt(i+5))%> (<%=((String)vMaintRecord.elementAt(i+7))%>) with <%=((String)vMaintRecord.elementAt(i+6))%> (<%=((String)vMaintRecord.elementAt(i+8))%>) 
                <%}%>
                </font></div></td>
            <td colspan="2" align="center" class="thinborder"><font size="1"><%=((String)vMaintRecord.elementAt(i+3))%></font></td>
          </tr>
          <%}%>
          <tr bordercolor="#111111"> 
            <td align="center" class="thinborder">&nbsp;</td>
            <td colspan="3" align="center" class="thinborder">&nbsp;</td>
            <td colspan="2" align="center" class="thinborder">&nbsp;</td>
          </tr>
        </table> 
		<%}%>
	  </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="info_index">
  <input type="hidden" name="page_action">
  <input type="hidden" name="proceedClicked" value="">
	<input type="hidden" name="is_component" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
