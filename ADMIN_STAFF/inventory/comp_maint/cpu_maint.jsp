<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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

function SearchComponent(){
	var pgLoc = "../comp_log/search_component.jsp?opner_info=form_.comp_prop_num&is_component=1";
	var win=window.open(pgLoc,"SearchProperty",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function SearchReplacement(){
	var pgLoc = "../comp_log/search_component.jsp?opner_info=form_.replacement";
	var win=window.open(pgLoc,"SearchProperty",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function OpenSearch()
{
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.requested_by";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage()
{
	document.form_.proceedClicked.value = "1";
	document.form_.pageReloaded.value = "1";
	this.SubmitOnce('form_');
}
function Cancel(){
	document.form_.proceedClicked.value = "1";
	document.form_.comp_prop_num.value = "";	
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}

function PageAction(strAction, strInfoIndex, strPropNum) {
	document.form_.prepareToEdit.value = "0";
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strPropNum.length > 0){
		document.form_.comp_prop_num.value = strPropNum;
		document.form_.prepareToEdit.value = "1";
	}
	document.form_.proceedClicked.value = "1";
	document.form_.page_action.value = strAction;	
	document.form_.pageReloaded.value = "1";
	this.SubmitOnce('form_');
}
</script>
</head>
<%@ page language="java" import="utility.*, java.util.Vector, inventory.InventoryLog, 
								inventory.InvCPUMaintenance" buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strPageAction  = null;
	String strAction = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Clearance-Clearance Management-Manage Signatories","cpu_maint.jsp");
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
														"Inventory","COMP_INV",request.getRemoteAddr(),
														"cpu_maint.jsp");
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
	InventoryLog InvLog = new InventoryLog();
	InvCPUMaintenance InvMaint = new InvCPUMaintenance();
	Vector vCompInfo= null;
	Vector vItemInfo  = null;
	Vector vReplacementInfo  = null;
	Vector vCPUParts = null;
	strPageAction = WI.fillTextValue("page_action");
	strTemp2 = WI.fillTextValue("entry_type");
	String[] astrAttachType = {"External","Built in"};
	String[] astrUnitMeasure = {"","inches", "Mb", "Gb", "Mhz", "Ghz"};	
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");	
	int iSearchResult = 0;
	
	if (strPageAction.length() > 0){
		 if(InvMaint.operateOnComponent(dbOP, request, Integer.parseInt(strPageAction)) == false ){			
			strErrMsg = InvMaint.getErrMsg();
			if(!strPageAction.equals("1"))
				strPrepareToEdit = "1";
		 }else{
		 	strPrepareToEdit = "0";
			if(strPageAction.equals("0"))
			   strErrMsg = "Component Delete successful.";							

			if(strPageAction.equals("1"))
			   strErrMsg = "Component added successfully";
			
			if(strPageAction.equals("2"))
			   strErrMsg = "Component successfully replaced";
		 }
	}

	if (WI.fillTextValue("prop_num").length() > 0){
		vCompInfo= InvLog.operateOnComponentsInv(dbOP,request,3);
		if(vCompInfo == null || vCompInfo.size() == 0)
			strErrMsg = InvLog.getErrMsg();
		else{
			vCPUParts = InvLog.operateOnComponentsInv(dbOP, request,5);
			iSearchResult = InvLog.getSearchCount();			
		}
	}		
	if (WI.fillTextValue("comp_prop_num").length() > 0){
		vItemInfo = InvLog.operateOnComponentsInv(dbOP,request,6);
		if (vItemInfo == null || vItemInfo.size() == 0){		
			strErrMsg = "Component property information not found";
		}
	}
	
	if (WI.fillTextValue("replacement").length() > 0){
		vReplacementInfo = InvLog.operateOnComponentsInv(dbOP,request,7);
	//	System.out.println("vReplacement Info" + vReplacementInfo);
		if (vReplacementInfo == null || vReplacementInfo.size() == 0){		
			strErrMsg = InvLog.getErrMsg();
		}
	}		
%>
<body bgcolor="#D2AE72">
<form name="form_" action="cpu_maint.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::INVENTORY 
          - CPU MAINTENANCE::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4"><font size="3" color="red"><%=WI.getStrValue(strErrMsg,"")%></font></td>
    </tr>
    <tr> 
      <td width="2%" height="30">&nbsp;</td>
      <td width="12%"><strong>Property # </strong></td>
      <td width="29%" valign="middle"><strong> 
        <%if(WI.fillTextValue("pageAction").equals("1") && vCompInfo != null)
	  		strTemp = (String)vCompInfo.elementAt(10);
	    else if(WI.fillTextValue("prop_num").length() > 0)
	  		strTemp = WI.fillTextValue("prop_num");
	  	else
			strTemp = "";
	  %>
      <input type="text" name="prop_num" class="textbox" value="<%=strTemp%>"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </strong></td>
      <td width="57%" valign="middle"><a href="javascript:SearchProperty();"><img src="../../../images/search.gif" alt="search" border="0"></a><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
<%if (vCompInfo!= null && vCompInfo.size() > 0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="29" colspan="6" bgcolor="#C78D8D"><strong><font color="#FFFFFF">CPU 
        DETAILS</font></strong></td>
    </tr>
    <tr> 
		<%if(vCompInfo != null && vCompInfo.size() > 0)
			strTemp = (String) vCompInfo.elementAt(0);
		%>
	  <input type="hidden" name="computer_index" value="<%=WI.getStrValue(strTemp,"")%>">
      <td width="2%" height="26">&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <td width="17%">Property Number </td>
      <td width="34%">: 
        <% if (vCompInfo!= null && vCompInfo.size() > 0)
	  		strTemp = (String) vCompInfo.elementAt(9);
	  %>
        <strong><%=WI.getStrValue(strTemp,"")%></strong></td>
      <td width="15%">Warranty Until</td>
      <td width="30%">: 
        <% if (vCompInfo!= null && vCompInfo.size() > 0)
	  		strTemp = (String) vCompInfo.elementAt(13);
	  %> <strong><%=WI.getStrValue(strTemp,"")%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td width="17%">Product Number </td>
      <td width="34%">: 
        <% if (vCompInfo!= null && vCompInfo.size() > 0)
	  		strTemp = (String) vCompInfo.elementAt(11);
	  %> <strong><%=WI.getStrValue(strTemp,"")%></strong></td>
      <td>Serial Number</td>
      <td>: 
        <% if (vCompInfo!= null && vCompInfo.size() > 0)
	  		strTemp = (String) vCompInfo.elementAt(10);
	  %> <strong><%=WI.getStrValue(strTemp,"")%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4">Description : 
        <% if (vCompInfo!= null && vCompInfo.size() > 0)
	  		strTemp = (String) vCompInfo.elementAt(22);
	  %> <strong><%=WI.getStrValue(strTemp,"")%></strong></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18" colspan="6"><hr size="1"></td>
    </tr>
  </table>
	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="4%">&nbsp;</td>
      <td width="25%">Date </td>
      <td width="71%" height="30" valign="middle">
      <% 
	  	strTemp = WI.getStrValue(WI.fillTextValue("eff_date"),"");
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		  %>
        <input name="eff_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.eff_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <%if(strPrepareToEdit.equals("1")) {%>
    <tr> 
      <td height="24" valign="middle">&nbsp;</td>
      <td height="24" valign="middle">Action Taken </td>
      <td height="24" valign="middle"> 
	  <% 
	  	strAction = WI.getStrValue(WI.fillTextValue("update_action"),"0");
	  %> <select name="update_action" onChange="ReloadPage();">
          <%if(strAction.equals("0")){%>
		  <option value="0" selected>Remove</option>
		  <option value="2">Replace</option>		  
          <%}else if(strAction.equals("2")){%>
          <option value="0">Remove</option>          
		  <option value="2" selected>Replace</option>          
          <%}else{%>
		  <option value="0" selected>Remove</option>
		  <option value="2">Replace</option>		  
		  <%}%>
        </select></td>
    </tr>
    <%}%>
    <tr> 
      <td height="24" valign="middle">&nbsp;</td>
      <td height="24" valign="middle">Component</td>
      <td height="24" valign="middle"> 
	  <%
		  strTemp = WI.fillTextValue("comp_prop_num");
	  %> 
        <input type="text" name="comp_prop_num" class="textbox" value="<%=WI.getStrValue(strTemp,"")%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
       <strong><font size="1">
		<a href="javascript:SearchComponent();"><img src="../../../images/search.gif" alt="search" border="0"></a>
		<a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" alt="search" width="71" height="23" border="0"></a>
		</font></strong></td>
    </tr>
    <%if(vItemInfo != null && vItemInfo.size() > 0){%>
    <tr> 
      <td height="18" valign="middle">&nbsp;</td>
      <td height="18" colspan="2" valign="middle"> <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td height="20"><font size="1">Item Name</font></td>
            <td><font size="1">: 
              <% if (vItemInfo != null && vItemInfo .size() > 0)
	  		  strTemp = (String) vItemInfo.elementAt(20);
	        %>
              <strong><%=WI.getStrValue(strTemp,"")%></strong></font></td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td height="20" width="25%"><font size="1">Property Number </font></td>
            <td width="25%"><font size="1">: 
              <% if (vItemInfo != null && vItemInfo .size() > 0)
	  		  strTemp = (String) vItemInfo.elementAt(9);
	        %>
              <strong><%=WI.getStrValue(strTemp,"")%></strong></font></td>
            <td width="25%"><font size="1">Warranty Until</font></td>
            <td width="25%"><font size="1">: 
              <% if (vItemInfo != null && vItemInfo.size() > 0)
	  		  strTemp = (String) vItemInfo.elementAt(13);
			%>
              <strong><%=WI.getStrValue(strTemp,"")%></strong></font></td>
          </tr>
          <tr> 
            <td><font size="1">Product Number </font></td>
            <td><font size="1">: 
              <% if (vItemInfo != null && vItemInfo .size() > 0)
	  		strTemp = (String) vItemInfo .elementAt(11);
	  		  %>
              <strong><%=WI.getStrValue(strTemp,"")%></strong></font></td>
            <td><font size="1">Serial Number</font></td>
            <td><font size="1">: 
              <% if (vItemInfo != null && vItemInfo .size() > 0)
	  		strTemp = (String) vItemInfo .elementAt(10);
			  %>
              <strong><%=WI.getStrValue(strTemp,"")%></strong></font></td>
          </tr>
          <tr> 
            <td><font size="1">CPU Property Number</font></td>
            <td><font size="1">: 
              <% if (vItemInfo != null && vItemInfo .size() > 0)
	  		strTemp = (String) vItemInfo .elementAt(18);
	  		  %>
              <strong><%=WI.getStrValue(strTemp,"")%></strong></font></td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
        </table></td>
    </tr>
    <%}%>
    <%if (strAction != null && strAction.equals("2")){%>
    <tr> 
      <td height="18" valign="middle">&nbsp;</td>
      <td height="18" valign="middle">Replacement</td>
      <td height="18" valign="middle"> <%
		  strTemp = WI.fillTextValue("replacement");
	  %> <strong> 
        <input type="text" name="replacement" class="textbox" value="<%=WI.getStrValue(strTemp,"")%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="1"><a href="javascript:SearchReplacement();"><img src="../../../images/search.gif" alt="search" border="0"></a><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" alt="search" width="71" height="23" border="0"></a></font></strong></td>
    </tr>    
	<%if(vReplacementInfo != null && vReplacementInfo.size() > 0){%>
    <tr> 
      <td height="18" valign="middle">&nbsp;</td>
      <td height="18" colspan="2" valign="middle"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td height="20"><font size="1">Item Name</font></td>
            <td><font size="1">: 
              <% if (vItemInfo != null && vItemInfo .size() > 0)
	  		  strTemp = (String) vItemInfo.elementAt(20);
	        %>
              <strong><%=WI.getStrValue(strTemp,"")%></strong></font></td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td height="20" width="25%"><font size="1">Property Number </font></td>
            <td width="25%"><font size="1">: 
              <% 
			 	//System.out.println("vReplacementInfo " + vReplacementInfo);
			 if (vReplacementInfo != null && vReplacementInfo .size() > 0)
	  		  strTemp = (String) vReplacementInfo.elementAt(9);
	        %>
              <strong><%=WI.getStrValue(strTemp,"")%></strong></font></td>
            <td width="25%"><font size="1">Warranty Until</font></td>
            <td width="25%"><font size="1">: 
              <% if (vReplacementInfo != null && vReplacementInfo.size() > 0)
	  		  strTemp = (String) vReplacementInfo.elementAt(13);
			%>
              <strong><%=WI.getStrValue(strTemp,"")%></strong></font></td>
          </tr>
          <tr> 
            <td><font size="1">Product Number </font></td>
            <td><font size="1">: 
              <% if (vReplacementInfo != null && vReplacementInfo.size() > 0)
	  		strTemp = (String) vReplacementInfo.elementAt(11);
	  		  %>
              <strong><%=WI.getStrValue(strTemp,"")%></strong></font></td>
            <td><font size="1">Serial Number</font></td>
            <td><font size="1">: 
              <% if (vReplacementInfo != null && vReplacementInfo.size() > 0)
	  			strTemp = (String) vReplacementInfo.elementAt(10);
			  %>
              <strong><%=WI.getStrValue(strTemp,"")%></strong></font></td>
          </tr>
          <tr> 
            <td><font size="1">CPU Property Number</font></td>
            <td><font size="1">: 
              <% if (vReplacementInfo != null && vReplacementInfo.size() > 0)
	  			strTemp = (String) vReplacementInfo.elementAt(18);
	  		  %>
              <strong><%=WI.getStrValue(strTemp,"")%></strong></font></td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
        </table></td>
    </tr>
	<%}// end if vReplacementInfo != null%>
	<%}%>
    <tr> 
      <td height="18" valign="middle">&nbsp;</td>
      <td height="18" valign="middle">Maintenance performed by</td>
      <td height="18" valign="middle"><strong> 
        <%
		  strTemp = WI.fillTextValue("maintained_by");
	  %>
        </strong> <input name="maintained_by" type="text" class="textbox" size="20" maxlength="64" value="<%=WI.getStrValue(strTemp,"")%>"></td>
    </tr>
    <tr> 
      <td height="18" colspan="3" valign="middle">&nbsp;</td>
    </tr>
  </table> 

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="18" colspan="2" valign="middle"><div align="center"><font size="1"> 
		 <%if(!strPrepareToEdit.equals("1")) {%>
          <a href='javascript:PageAction("1","","")'> <img src="../../../images/add.gif" alt="save" width="42" height="32" border="0"></a>click 
          to add entry                    
		  <%}else{%>
			  <%  
			  	  if (vItemInfo!= null && vItemInfo.size() > 0){
					strTemp = (String) vItemInfo.elementAt(0);
				  }			 
			  %>
          <a href='javascript:PageAction("<%=strAction%>", "<%=WI.getStrValue(strTemp,"")%>","");'><img src="../../../images/edit.gif" border="0"></a> 
          Click to edit entry <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
          Click to cancel 
          <%}%>
          </font></div></td>
    </tr>
    <tr>
      <td height="18" colspan="2" valign="middle">&nbsp;</td>
    </tr>
  </table>

  <%} // end vCompInfo!= null%>  
  <%if (vCPUParts != null && vCPUParts.size() > 0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="23" colspan="8" class="thinborder"><div align="center"> 
          <p><strong><font size="2"> COMPONENTS FOR THE SELECTED CPU</font></strong></p>
        </div></td>
    </tr>
    <tr> 
      <td  height="25" colspan="5" align="left" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td  height="25" colspan="3" align="left" class="thinborderBOTTOM">&nbsp;</td>
    </tr>
    <tr> 
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>PROPERTY 
        NUMBER </strong></font></td>
      <td width="16%" height="25" align="center" class="thinborder"><font size="1"><strong>ITEM 
        NAME </strong></font></td>
      <td width="14%" class="thinborder" align="center"><font size="1"><strong>ATTACHMENT 
        TYPE </strong></font></td>
      <td width="12%" class="thinborder" align="center"><font size="1"><strong>SIZE/CAPACITY</strong></font></td>
      <td width="13%" class="thinborder" align="center"><font size="1"><strong>SERIAL 
        NUMBER </strong></font></td>
      <td width="14%" class="thinborder" align="center"><font size="1"><strong>PRODUCT 
        NUMBER</strong></font></td>
      <td width="12%" class="thinborder" align="center"><font size="1"><strong>STATUS</strong></font></td>
      <td width="9%" align="center" class="thinborder"><font size="1"><strong>OPTION</strong></font></td>
    </tr>
    <%for (int i=0; i< vCPUParts.size(); i+=31) {%>
    <tr> 
      <td class="thinborder"><font size="1">&nbsp;&nbsp;<%=((String)vCPUParts.elementAt(i+9))%></font></td>
      <td class="thinborder"><font size="1">&nbsp;&nbsp;<%=((String)vCPUParts.elementAt(i+20))%></font></td>
      <td class="thinborder"><font size="1">&nbsp;&nbsp;<%=(astrAttachType[Integer.parseInt((String)vCPUParts.elementAt(i+14))])%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vCPUParts.elementAt(i+16),"&nbsp;")%> <%=astrUnitMeasure[Integer.parseInt(WI.getStrValue((String)vCPUParts.elementAt(i+21),"0"))]%>&nbsp;</font></td>
      <td class="thinborder"><font size="1">&nbsp;&nbsp;<%=WI.getStrValue((String)vCPUParts.elementAt(i+10),"&nbsp;")%></font></td>
      <td class="thinborder"><font size="1">&nbsp;&nbsp;<%=WI.getStrValue((String)vCPUParts.elementAt(i+11),"&nbsp;")%></font></td>
      <td class="thinborder"><font size="1">&nbsp;&nbsp;<%=((String)vCPUParts.elementAt(i+22))%></font></td>
      <td align="left" class="thinborder"><a href='javascript:PageAction("","<%=(String)vCPUParts.elementAt(i)%>","<%=(String)vCPUParts.elementAt(i+9)%>")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
    <%}%>
    <tr> 
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <%}%>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>	
   <input type="hidden" name="info_index" value="">
   <input type="hidden" name="pageReloaded" value="">
   <input type="hidden" name="proceedClicked" value="">
   <input type="hidden" name="add_entry" value="">
   <input type="hidden" name="page_action">
   <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
