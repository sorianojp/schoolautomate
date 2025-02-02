<%@ page language="java" import="utility.*, inventory.*, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";

boolean bolIsVMA = strSchCode.startsWith("VMA");
boolean bolIsUB = strSchCode.startsWith("UB");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Computer set/part entry Log</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script>
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.proceedClicked.value = "1";
	document.form_.page_action.value = strAction;	
	document.form_.pageReloaded.value = "0";
	this.SubmitOnce('form_');
}

function ReloadPage()
{
	document.form_.proceedClicked.value = "1";
	document.form_.pageReloaded.value = "1";
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function Cancel() 
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ClearPropertyNo(){
	document.form_.prop_no.value ="";
}

function SearchCPU(){
	var pgLoc = "./search_component.jsp?is_component=0&opner_info=form_.cpu_prop_num";
	var win=window.open(pgLoc,"SearchProperty",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function goBack(strMainForm) {
	location = strMainForm + "inv_date="+document.form_.log_date.value+
						"&entry_type="+document.form_.entry_type.value+
						"&inventory_type="+document.form_.inventory_type.value+
						"&inv_date_fr="+document.form_.date_fr.value+
						"&inv_date_to="+document.form_.date_to.value+
						"&proceedClicked=1";
}
</script>
</head>
<%
	DBOperation dbOP = null;	
	//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-COMP_INV"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Inventory -COMP_LOG-COMPUTER_ENTRY_LOG","comp_entry_log_items.jsp");
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
	
	InventoryLog InvLog = new InventoryLog();
	
	Vector vEntryDetails = null;
//	Vector vPOItems = null;
	Vector vCompInfo = null;
 	Vector vRetResult = null;
	Vector vTemp = null;
	
	String strErrMsg = null;
	String strType = null;
	String strProcessor = null;
	String strInvType = null;	
	String strDonorIndex = null;	
	String strPageAction = null;
	String strTemp = null;
	String strTemp2 = null;
	String strAttachType = null;	
	String strPrepareToEdit = null;
	String strComponent = WI.fillTextValue("is_component");
	int iSearchResult = 0;
	int i = 0;
	String strFinCol = null;	
	String[] astrAttachType = {"External","Built in"};
	String[] astrUnitMeasure = {"n/a","inches", "Mb", "Gb", "Mhz", "Ghz"};
	String[] astrUnitVal     = {"0", "1", "2", "3", "4","5"};
	String strEntryIndex = WI.fillTextValue("entry_index");
	String strEntryType = WI.fillTextValue("entry_type");
	
	strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	
	strPageAction = WI.fillTextValue("page_action");

	vEntryDetails = InvLog.getEntryDetails(dbOP, request, strEntryIndex, strEntryType);	

  if (strPrepareToEdit.equals("1")){
			vCompInfo = InvLog.operateOnComponentsInv(dbOP, request, 8);		
  }
		
  if(strPageAction.length() > 0) {		
		 if(InvLog.operateOnComponentsInv(dbOP, request, Integer.parseInt(strPageAction)) == null )
			strErrMsg = InvLog.getErrMsg();
		 else{
			strPrepareToEdit = "0";
			if(strPageAction.equals("1"))
			   strErrMsg = "Component Log successful.";	

			if(strPageAction.equals("2"))
			   strErrMsg = "Component Log successfully edited.";				
		 }
	}	
int iElemCount = 0;	
		vRetResult = InvLog.operateOnComponentsInv(dbOP, request, 4);
		if(vRetResult == null)
			strErrMsg = InvLog.getErrMsg();
		else{
			iElemCount = InvLog.getElemCount();
			iSearchResult = InvLog.getSearchCount();
		}
		
			
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./comp_entry_log_items.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<%if (strComponent.equals("0")){%>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY LOG - COMPUTER ENTRY LOG PAGE ::::</strong></font></div></td>
    </tr>
	<%}else{%>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY LOG - CPU COMPONENT ENTRY LOG PAGE ::::</strong></font></div></td>
    </tr>
	<%}%>

    <tr> 
      <td width="76%" height="25">
			  <a href="javascript:goBack('<%=WI.fillTextValue("main_form")%>');">
				  <img src="../../../images/go_back.gif" width="50" height="27" border="0"></a>
				  <font size="2"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></font></td>
      <td width="24%">&nbsp;</td>
    </tr>
  </table>
  <%if (strEntryType.equals("1")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr  bgcolor="#A49A60"> 
      <td width="4%" height="27">&nbsp;</td>
      <td colspan="2"><font color="#FFFFFFF"><strong>ENDORSEMENT DETAILS</strong></font></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td width="19%"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
	 <%if(vEntryDetails!=null && vEntryDetails.size() > 0){		 
		strTemp = (String) vEntryDetails.elementAt(7);
	   }else{
		strTemp = "";
	   }		 
	 %>
      <td width="77%"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></td>
	 <%if(vEntryDetails!=null && vEntryDetails.size() > 0){		 
		strTemp = (String) vEntryDetails.elementAt(6);
	   }else{
		strTemp = WI.fillTextValue("c_index");
	   }		 
	 %>
	  <input type="hidden" name="c_index" value="<%=strTemp%>">
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Department</td>
	 <%if(vEntryDetails!=null && vEntryDetails.size() > 0){		 
		strTemp = (String) vEntryDetails.elementAt(9);
	   }else{
		strTemp = "";
	   }		 
	 %>	  
      <td><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></td>
	  	 <%if(vEntryDetails!=null && vEntryDetails.size() > 0){
		strTemp = (String) vEntryDetails.elementAt(8);
	   }else{
		strTemp = WI.fillTextValue("d_index");
	   }
	 %>
	  <input type="hidden" name="d_index" value="<%=strTemp%>">
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Request Type</td>
	 <%if(vEntryDetails!=null && vEntryDetails.size() > 0){		 
		strTemp = (String) vEntryDetails.elementAt(13);
	   }else{
		strTemp = "";
	   }		 
	 %>	  	  
      <td><strong><%if (strTemp.equals("0")){%>New<%}else{%>Replacement<%}%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Building</td>
      <td> 
	  <%
	  //if (!WI.fillTextValue("pageReloaded").equals("1")){
		  if (vCompInfo != null && vCompInfo.size() > 0)
				strTemp = WI.getStrValue((String)vCompInfo.elementAt(8),"");
		  else
			strTemp = WI.fillTextValue("bldg_index");	
	  //}else{
		//strTemp = WI.fillTextValue("bldg_index");	  
	  //}
	  %>
		<select name="bldg_index" onChange="ReloadPage();">
         <option value="">N/A</option>
          <%=dbOP.loadCombo("BLDG_INDEX","BLDG_NAME"," from E_ROOM_BLDG where IS_DEL=0 order by BLDG_NAME", strTemp, false)%> 
		</select>
        <%if(false){%>
        <img src="../../../images/update.gif"  border="0"> <font size="1"> click 
        to update list of BUILDINGS</font> 
        <%}%>
      </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Room</td>
      <td> 
	  <%
			if (vCompInfo != null && vCompInfo.size() > 0)
				strTemp2 = WI.getStrValue((String)vCompInfo.elementAt(7),"");
			else
				strTemp2 = WI.fillTextValue("room_idx");	
	  %>		 
		 <select name="room_idx" onChange="ReloadPage();">
          <option value="">N/A</option>
 		  <%
		  	if (strTemp.length()>0){
			strTemp = " from E_ROOM_DETAIL join E_ROOM_BLDG on (E_ROOM_DETAIL.LOCATION = E_ROOM_BLDG.BLDG_NAME) where BLDG_INDEX = "+strTemp+
			" and E_ROOM_DETAIL.is_del = 0 order by ROOM_NUMBER";
		   %>
          <%=dbOP.loadCombo("ROOM_INDEX","ROOM_NUMBER", strTemp, strTemp2, false)%> 
          <%}%>
      </select></td>
		
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Location Description</td>
      <td> 
        <%
		  if (vCompInfo != null && vCompInfo.size() > 0)
				strTemp = WI.getStrValue((String)vCompInfo.elementAt(19),"");
		  else
				strTemp = WI.fillTextValue("loc_desc");
		  %>		  
        <input name="loc_desc" type="text" class="textbox" size="32" maxlength="32" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="18" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <%}else{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td colspan="2"><strong><u>LOCATION</u></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="19%"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td width="77%"> 
  
	  <% 
	  if (!WI.fillTextValue("pageReloaded").equals("1")){
	  	 // System.out.println("true");
		  if (vCompInfo != null && vCompInfo.size() > 0)
			strTemp = WI.getStrValue((String)vCompInfo.elementAt(5),"");
		  else
			strTemp = WI.fillTextValue("c_index");
	  }else{
		strTemp = WI.fillTextValue("c_index");
	  }
	  %>	  
	<select name="c_index" onChange="ReloadPage();">
	  <option value="0">N/A</option>
	  <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department</td>
      <td> 
	  <% 	  
		  if (vCompInfo != null && vCompInfo.size() > 0)
				strTemp2 = WI.getStrValue((String)vCompInfo.elementAt(6),"");
		  else
				strTemp2 = WI.fillTextValue("d_index");
	  %>
	   <select name="d_index">
	        <%
						if (strTemp == null || strTemp.length() == 0 || strTemp.compareTo("0") == 0) {
			      	  strTemp = " and (c_index = 0 or c_index is null) ";
					%>
         <option value="0">Select Office</option>
        	 <%} else {
			    	  strTemp = " and c_index = " +  strTemp; %>
							<option value="0">ALL</option>
					  <%}%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 " + strTemp + " order by d_name asc",strTemp2, false)%> 
			</select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Building</td>
      <td>
      <% 
	  if (!WI.fillTextValue("pageReloaded").equals("1")){
		  if (vCompInfo != null && vCompInfo.size() > 0)
				strTemp = WI.getStrValue((String)vCompInfo.elementAt(8),"");
		  else
			strTemp = WI.fillTextValue("bldg_index");	
	  }else{
		strTemp = WI.fillTextValue("bldg_index");	  
	  }
	  %>
        <select name="bldg_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("BLDG_INDEX","BLDG_NAME"," from E_ROOM_BLDG where IS_DEL=0 order by BLDG_NAME", strTemp, false)%> </select>
        <%if(false){%>
        <img src="../../../images/update.gif"  border="0"><font size="1"> click 
        to update list of BUILDINGS
        <%}%>
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Room</td>
      <td> 
        <%
	  if (vCompInfo != null && vCompInfo.size() > 0)
			strTemp2 = WI.getStrValue((String)vCompInfo.elementAt(7),"");
	  else
			strTemp2 = WI.fillTextValue("room_idx");	
	  %>
        <select name="room_idx" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%
				if (strTemp.length()>0){
				strTemp = " from E_ROOM_DETAIL join E_ROOM_BLDG on (E_ROOM_DETAIL.LOCATION = E_ROOM_BLDG.BLDG_NAME) where BLDG_INDEX = "+strTemp+
				" and E_ROOM_DETAIL.is_del = 0 order by ROOM_NUMBER";
				%>
          <%=dbOP.loadCombo("ROOM_INDEX","ROOM_NUMBER", strTemp, strTemp2, false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Location Description</td>
      <td> 
        <%
		  if (vCompInfo != null && vCompInfo.size() > 0)
				strTemp = WI.getStrValue((String)vCompInfo.elementAt(19),"");
		  else
				strTemp = WI.fillTextValue("loc_desc");
		  %>
        <input name="loc_desc" type="text" class="textbox" size="32" maxlength="32" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="20" colspan="3"><hr size="1"></td>
    </tr>
	</table>
    <%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="5%" height="26">&nbsp;</td>
      <td width="29%">Item Name : <strong><%=(String)vEntryDetails.elementAt(2)%></strong></td>
			<%
			strTemp = (String)vEntryDetails.elementAt(3);
			//strTemp = CommonUtil.formatFloat(strTemp);
		//	System.out.println("strTemp " + strTemp);
			%>
      <td width="25%">Quantity : <strong><%=strTemp%></strong>
			<input type="hidden" name="total_quantity" value="<%=strTemp%>"></td>	  
      <td width="41%">Unit : <strong><%=(String)vEntryDetails.elementAt(5)%></strong></td>
    </tr>
    <!--
	<tr> 
      <td height="26">&nbsp;</td>
      <td colspan="3">Particulars/Item Description : <strong> 
        <%if (strEntryType.equals("1")){%>
        <%=(String)vEntryDetails.elementAt(12)%> 
        <%} else {%>
        None
        <%}%>
        </strong></td>
    </tr>
    -->
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="3">Current inventory on hand for this ITEM for the Specified 
        Location: 
		<% 
		vTemp = InvLog.operateOnGetItems(dbOP, request);

        if (vTemp != null && vTemp.size()>0){%> 
				<strong><%=WI.getStrValue((String)vTemp.elementAt(0),"0")%></strong> 
				<%} else {%>
        	0
        <%}%>				</td>
    </tr>
    <tr> 
      <td height="18" colspan="4"><hr size="1"></td>
    </tr>
  </table>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td>Property #</td>
      <td colspan="2">
	  <%
	  if (vCompInfo != null && vCompInfo.size() > 0)
			strTemp = WI.getStrValue((String)vCompInfo.elementAt(9),"");
	  else
			strTemp = WI.fillTextValue("prop_no");
	  %>
	  <input name="prop_no" type="text" class="textbox" size="32" maxlength="32" value="<%=WI.getStrValue(strTemp,"")%>"> 
        <font size="1">&nbsp; </font><font size="1">(required)
        <input type="hidden" name="old_prop_num" value="<%=WI.getStrValue(strTemp,"")%>">
        </font>
			
	<%if(bolIsUB){%><input type="checkbox" name="auto_gen" value="1">Auto-generate property number	<%}%>	</td>
    </tr>
	<%if(strComponent.equals("1")){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Attachment Type :</td>
      <td colspan="2">
			<%
			if (vCompInfo != null && vCompInfo.size() > 0)
				strAttachType = WI.getStrValue((String)vCompInfo.elementAt(14),"");
			else
				strAttachType = WI.fillTextValue("attachment_type");			
			%>	  
        <select name="attachment_type">
          <option value="" selected>Select Type</option>
          <%if (strAttachType.equals("0")){%>
          <option value="0" selected>External</option>
          <option value="1">Built In</option>
          <%}else if (strAttachType.equals("1")){%>
          <option value="0">External</option>
          <option value="1" selected>Built In</option>
          <%} else {%>
          <option value="0">External</option>
          <option value="1">Built In</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Size/capacity:</td>
      <td colspan="2">
       <%
   	  if (vCompInfo!=null && vCompInfo.size()>0)
      	strTemp = WI.getStrValue((String)vCompInfo.elementAt(16),"");
      else
	    strTemp = WI.fillTextValue("capacity");
	  %>
        <input name="capacity" type="text" class="textbox" size="32" maxlength="32" value="<%=WI.getStrValue(strTemp,"")%>"
		onKeyUp="AllowOnlyIntegerExtn('form_','capacity','.')" onBlur="AllowOnlyIntegerExtn('form_','capacity','.')"
		> 
        <%
   	  if (vCompInfo!=null && vCompInfo.size()>0)
      	strTemp = WI.getStrValue((String)vCompInfo.elementAt(21),"");
      else
	    strTemp = WI.fillTextValue("capacity_unit");
	  %>
        <select name="capacity_unit">
          <option value="" selected>Unit of Measure</option>
          <%
		  for (i = 0; i<5 ; i++){
		  %>
          <%if(strTemp.equals(astrUnitVal[i])){%>
          <option value="<%=astrUnitVal[i]%>" selected><%=astrUnitMeasure[i]%></option>
          <%} else {%>
          <option value="<%=astrUnitVal[i]%>"><%=astrUnitMeasure[i]%></option>
          <%}%>
          <%}%>
        </select></td>
    </tr>
   <!--
	  <tr> 
      <td height="25">&nbsp;</td>
      <td>Brand:</td>
      <td colspan="2">
        <%
   	  if (vCompInfo!=null && vCompInfo.size()>0)
      	strTemp = WI.getStrValue((String)vCompInfo.elementAt(17),"");
      else
	    strTemp = WI.fillTextValue("brand");
	  %>
        <input type="text" name="starts_with" value="<%//=WI.fillTextValue("starts_with")%>" size="6" class="textbox"
	   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   onKeyUp = "AutoScrollList('form_.starts_with','form_.brand',true);" > 
        <%//if(vRetResult != null && vRetResult.size() > 3)
			//	strTemp = (String)vRetResult.elementAt(8);
		  //		else
	    //	strTemp = WI.fillTextValue("brand");%>
        <select name="brand">
          <option value="">Select brand</option>
          <%//=dbOP.loadCombo("BRAND_INDEX","BRAND_NAME"," from PUR_PRELOAD_BRAND " + 
						//							" where inv_cat_index = " + WI.getStrValue(WI.fillTextValue("inv_cat_index"),"-1") +
						//								"order by BRAND_NAME asc", strTemp, false)%>
        </select></td>
    </tr>
		-->
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="19%">CPU Property #
	  <font size="1">(optional)</font>
	  </td>
      <td width="33%">
        <%
   	  if (vCompInfo!=null && vCompInfo.size()>0)
      	strTemp = WI.getStrValue((String)vCompInfo.elementAt(18),"");
      else
	    strTemp = WI.fillTextValue("cpu_prop_num");
	   %>
        <input name="cpu_prop_num" type="text" class="textbox" size="16" maxlength="16" value="<%=WI.getStrValue(strTemp,"")%>"> 
        
		<%if(bolIsUB){%><input type="checkbox" name="cpu_auto_gen" value="1">Auto-generate CPU property number<%}%>
		</td>
      <td width="44%"><font size="1"><strong><font size="1"><a href="javascript:SearchCPU();"><img src="../../../images/search.gif" alt="search" border="0" align="absbottom"></a></font></strong>Click to search for CPU Property where item is attached 
      </font></td>
    </tr>
    <%}else{%>
    <%if (vCompInfo!=null && vCompInfo.size()>0)
      	strTemp = WI.getStrValue((String)vCompInfo.elementAt(10),"");
     else
	    strTemp = WI.fillTextValue("prop_no");
	 %>
    <input name="prop_no" type="hidden" class="textbox" value="<%=WI.getStrValue(strTemp,"")%>">
    <%}// if strComponent.equals 1%>
	
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td>Serial #</td>
      <td colspan="2">	  
	  <%
	  if (vCompInfo != null && vCompInfo.size() > 0)
			strTemp = WI.getStrValue((String)vCompInfo.elementAt(10),"");
	  else
		strTemp = WI.fillTextValue("serial_no");
	  %>	  
        <input name="serial_no" type="text" class="textbox" size="15" maxlength="15" value="<%=strTemp%>"> 
        <font size="1"> &nbsp;(if Applicable)</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Product #</td>
      <td colspan="2">	  
	  <%
	  if (vCompInfo != null && vCompInfo.size() > 0)
			strTemp = WI.getStrValue((String)vCompInfo.elementAt(11),"");	
	  else
			strTemp = WI.fillTextValue("prod_no");
	  %>	  	  
        <input name="prod_no" type="text" class="textbox" size="15" maxlength="15" value="<%=strTemp%>"> 
        <font size="1"> &nbsp;(if Applicable)</font></td>
    </tr>
	<%if(strComponent.equals("0")){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Processor Type</td>
      <td colspan="2"> 
	  <%
	  if (vCompInfo != null && vCompInfo.size() > 0)
			strProcessor = WI.getStrValue((String)vCompInfo.elementAt(29),"");	
	  else
			strProcessor = WI.fillTextValue("processor_type");
	  %>	  	  
	  <select name="processor_type">
		  <option value="0">Server</option>
		  <%if (WI.getStrValue(strProcessor,"").equals("1")){%>
		  <option value="1" selected>Workstation</option>
		  <%} else {%>
		  <option value="1">Workstation</option>
		  <%}%>
       </select></td>
    </tr>
	<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Price</td>
      <td colspan="2"> 
	  <%
	  if (vCompInfo != null && vCompInfo.size() > 0)
			strTemp = WI.getStrValue((String)vCompInfo.elementAt(4),"");
	  else
			strTemp = WI.fillTextValue("price");
	  %>	    
        <input name="price" type="text" class="textbox" size="15" maxlength="10" value="<%=strTemp%>"
		onKeyUp="AllowOnlyIntegerExtn('form_','price','.')" onBlur="AllowOnlyIntegerExtn('form_','price','.')">	 </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Description</td>
      <td colspan="2"> 
	  <%
	  if (vCompInfo != null && vCompInfo.size() > 0)
			strTemp = WI.getStrValue((String)vCompInfo.elementAt(28),"");
	  else
			strTemp = WI.fillTextValue("description");
	  %>
        <input name="description" type="text" class="textbox" size="32" maxlength="64" value="<%=strTemp%>"></td>
    </tr>
	
	<tr>
      <td height="24">&nbsp;</td>
	  <%
	  if(!bolIsVMA)
	  	strTemp = "Additional Details";
	else
		strTemp = "Remarks";
	  %>
      <td><strong><%=strTemp%></strong></td>
      <td colspan="2">
	  <%
	  strTemp = WI.fillTextValue("addtl_dtls");
	  if (vCompInfo != null && vCompInfo.size() > 0)
			strTemp = WI.getStrValue((String)vCompInfo.elementAt(33));
	  %>
        <input name="addtl_dtls" type="text" class="textbox" size="32" maxlength="32" value="<%=strTemp%>"
			 onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'>
        <font size="1"> &nbsp;(if Applicable)</font></td>
    </tr>

    <tr> 
      <td height="25">&nbsp;</td>
      <td>Status</td>
      <td colspan="2"> 
	  <%
	  if (vCompInfo != null && vCompInfo.size() > 0)
			strTemp = WI.getStrValue((String)vCompInfo.elementAt(12),"");
	  else
			strTemp = WI.fillTextValue("stat_index");
	  %>
	  <select name="stat_index">
          <option value="">Select Status</option>
          <%=dbOP.loadCombo("inv_stat_index","inv_status"," from inv_preload_status " +
					" where is_default = 0 order by inv_status", strTemp, false)%> </select> <font size="1">&nbsp; </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Warranty Until </td>
      <td colspan="2"> 
	  <%
	  if (vCompInfo != null && vCompInfo.size() > 0)
			strTemp = WI.getStrValue((String)vCompInfo.elementAt(13),"");
	  else
			strTemp = WI.fillTextValue("warranty");
	  %>	  
	  <input name="warranty" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.warranty');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Date Acquired </td>
      <td colspan="2"><%
   	  if (vCompInfo!=null && vCompInfo.size()>0)
      	strTemp = WI.getStrValue((String)vCompInfo.elementAt(30),"");
      else
      	strTemp = WI.fillTextValue("date_acquired");
			if(strTemp == null)
				strTemp = WI.fillTextValue("log_date");
			%>
        <input name="date_acquired" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.date_acquired');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
	
		<%
if(bolIsVMA){
%>

	<tr>
        <td height="25">&nbsp;</td>
        <td>Life Span</td>
		<%

		String[] astrLifeSpanUnit = {"Day(s)","Month(s)", "Year(s)"};
		
		strTemp = WI.fillTextValue("life_span");
		if (vCompInfo!=null && vCompInfo.size()>0)
      		strTemp = WI.getStrValue((String)vCompInfo.elementAt(31)); 
		%>
        <td>
		<input name="life_span" type="text" size="3" maxlength="3" value="<%=strTemp%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp;
		<select name="life_span_unit">
		<%
		strTemp = WI.fillTextValue("life_span_unit");
		if (vCompInfo!=null && vCompInfo.size()>0)
      		strTemp = WI.getStrValue((String)vCompInfo.elementAt(32));  
		for(i = 0; i < astrLifeSpanUnit.length; ++i){
		if(strTemp.equals(Integer.toString(i)))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%>
		<option value="<%=i%>" <%=strErrMsg%>><%=astrLifeSpanUnit[i]%></option>
		<%}%>
		</select>
		</td>
    </tr>

<!--    <tr>
        <td height="25">&nbsp;</td>
        <td>Life Span</td>
		<%
		strTemp = WI.fillTextValue("life_span");
		if (vCompInfo!=null && vCompInfo.size()>0)
      		strTemp = WI.getStrValue((String)vCompInfo.elementAt(31));
		%>
        <td>
		<input name="life_span" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.life_span');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
		</td>
    </tr>-->
<%}%>	
	
	
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25"> <div align="center"><font size="1"> 
          <%if(strPrepareToEdit.compareTo("1") != 0) {%>
          <a href='javascript:PageAction(1,"");'> <img src="../../../images/save.gif" border="0" name="hide_save"></a> 
          Click to add entry 
          <%}else{%>		  
		  <%
		  if (vCompInfo != null && vCompInfo.size() > 0)
			strTemp = WI.getStrValue((String)vCompInfo.elementAt(0),"");
		  %>
          <a href='javascript:PageAction(2, "<%=WI.getStrValue(strTemp,"")%>");'><img src="../../../images/edit.gif" border="0"></a> 
          Click to edit entry <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
          Click to cancel 
          <%}%>
          </font> </div></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
    </tr>
  </table>
  <% if (vRetResult != null && vRetResult.size()>0){%>

  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="25" colspan="6" class="thinborder"><div align="center"> 
          <p><strong><font size="2"> INVENTORY ENTRY LIST FOR THE DATE (<%=WI.fillTextValue("inv_date")%>)</font></strong></p>
        </div></td>
    </tr>
    <tr> 
      <td  height="25" colspan="2" class="thinborderBOTTOMLEFT" align="left"><font size="1"><strong>TOTAL 
        ITEMS: &nbsp;&nbsp;<%=iSearchResult%></strong></font></td>
      <td colspan="4" align="right" class="thinborderBOTTOM"><%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/InvLog.defSearchSize;
		if(iSearchResult % InvLog.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1){%> <select name="jumpto" onChange="ReloadPage();" style="font-size:11px">
          <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
          <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%	}
			}// end page printing
			%>
        </select> <%} else {%> &nbsp; <%} //if no pages %></td>
    </tr>
    <tr valign="top">
      <td width="208" height="20" align="center" class="thinborder"><font size="1"><strong>LOCATION</strong></font></td>
      <td width="141" align="center" class="thinborder"><font size="1"><strong>PROPERTY 
      DETAILS</strong></font></td>
      <td width="60" align="center" class="thinborder"><font size="1"><strong>STATUS</strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>SUPPLIER 
        / DONOR</strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>WARRANTY 
        UNTIL </strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>OPTIONS</strong></font></td>
    </tr>
    <% 
	for (i =0; i<vRetResult.size(); i+=iElemCount){%>
    <tr>
      <td valign="top" class="thinborder"><font size="1"> 
        <%=WI.getStrValue((String)vRetResult.elementAt(i+25),"Building: ","<br>","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+26),"Room: ","<br>","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+19),"Location: ","","")%> </font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+9),"Property #: ","<br>","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+10),"Serial   #: ","<br>","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+11),"Product  #: ","<br>","")%>&nbsp; </font></td>
      <td align="center" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+22)%></font></td>
      <td width="105" class="thinborder"><font size="1"> &nbsp;
        <%if (strEntryType.equals("1")){%>
        <%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%> 
        <%}else if (strEntryType.equals("0")){%>
        <%=WI.getStrValue((String)vRetResult.elementAt(i+23),"&nbsp;")%> 
        <%}%>
      </font></td>
      <td width="103" align="center" class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+13),"&nbsp;")%></font></td>
      <td width="122" align="center" class="thinborder">	    
	  		<a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'> <img src="../../../images/edit.gif" border="0"></a>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
    <%}%>
  </table>	
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

  	<input type="hidden" name="info_index"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="proceedClicked" value="">
    <input type="hidden" name="page_action">
	<input type="hidden" name="inventory_type" value="3">
	<input type="hidden" name="pageReloaded" value="">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="po_num" value="<%=WI.fillTextValue("po_num")%>">
	<input type="hidden" name="is_component" value="<%=WI.fillTextValue("is_component")%>">
	<input type="hidden" name="entry_type" value="<%=WI.fillTextValue("entry_type")%>">
	<input type="hidden" name="inv_date" value="<%=WI.fillTextValue("inv_date")%>">
	<input type="hidden" name="entry_index" value="<%=WI.fillTextValue("entry_index")%>">
	<input type="hidden" name="inv_cat_index" value="<%=WI.fillTextValue("inv_cat_index")%>">
	
	<input type="hidden" name="item_index" value="<%=WI.fillTextValue("item_index")%>">	
	<input type="hidden" name="reference_index" value="<%=WI.fillTextValue("reference_index")%>">
	<input type="hidden" name="log_date" value="<%=WI.fillTextValue("log_date")%>">
	<input type="hidden" name="brand" value="<%=WI.fillTextValue("brand")%>">
	<input type="hidden" name="conversion_qty" value="<%=WI.fillTextValue("conversion_qty")%>">
	
	<input type="hidden" name="main_form" value="<%=WI.fillTextValue("main_form")%>">	
	<input type="hidden" name="date_fr" value="<%=WI.fillTextValue("date_fr")%>">	
	<input type="hidden" name="date_to" value="<%=WI.fillTextValue("date_to")%>">		
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>