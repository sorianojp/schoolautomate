<%@ page language="java" import="utility.*, inventory.InvCPUMaintenance, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script>
function PageAction(strAction,strInfoIndex)
{		
	if(strAction==0){	 
		if(!confirm("This will reassign all related records. "+
		"Do you want to continue?"))
                             return;
	}	
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value= strAction;
	this.SubmitOnce("form_");
}
function ReloadPage()
{
	document.form_.focus_area.value = "1";
	this.SubmitOnce('form_');
}
function ReloadCollege() {
	document.form_.focus_area.value = "2";
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex, strPropNo) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.prop_no.value = strPropNo;
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
function OpenSearch()
{
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.transfer_by";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusStuff() {
	var pageNo = <%=WI.getStrValue(WI.fillTextValue("focus_area"),"1")%>
	eval('document.form_.area'+pageNo+'.focus()');
}

function SearchProperty(){
	var pgLoc = "./search_property.jsp?opner_info=form_.prop_no&transfer=1";
	var win=window.open(pgLoc,"PrintWindow",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function SearchCPU(){
	var pgLoc = "../comp_log/search_computer.jsp?opner_info=form_.prop_no";
	var win=window.open(pgLoc,"PrintWindow",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function SearchComponent(){
	var pgLoc = "../comp_log/search_component.jsp?opner_info=form_.prop_no";
	var win=window.open(pgLoc,"PrintWindow",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function SearchTransaction(){
	var pgLoc = "./search_comp_transfer.jsp?opner_info=form_.trans_no&item_type=0";
	var win=window.open(pgLoc,"SearchTransaction",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
</head>

<%
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-COMP_MAINTENANCE"),"0"));
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
								"INVENTORY-INVENTORY MAINTENANCE","component_transfer.jsp");
	
	Vector vRetResult = null;
	Vector vCPUResult = null;
	Vector vEditInfo = null;
	Vector vTransferNo = null;
//	Vector vEntryDetails = null;
	Vector vPropDtls = null;
	int i = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strPrepareToEdit = null;
	int iSearchResult = 0;
	String strFinCol = null;
		
	strTemp = WI.fillTextValue("page_action");
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");

	InvCPUMaintenance CPUMaint = new InvCPUMaintenance();

  if(WI.fillTextValue("prop_no").length()>0){   
		vPropDtls = CPUMaint.operateOnTransferComponent(dbOP, request, 5);
		if (vPropDtls ==  null)
			strErrMsg = CPUMaint.getErrMsg();
  }
	
	if(strTemp.length() > 0) {
		vTransferNo = CPUMaint.operateOnTransferComponent(dbOP, request, Integer.parseInt(strTemp));
		if(vTransferNo != null && vTransferNo.size() > 0){
		  strErrMsg = "Operation successful.";
		  strPrepareToEdit = "0";
	  }else 
		  strErrMsg = CPUMaint.getErrMsg();
	}
	
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = CPUMaint.operateOnTransferComponent(dbOP, request, 3);	
	if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = CPUMaint.getErrMsg();
	}
	vRetResult = CPUMaint.operateOnTransferComponent(dbOP, request, 4);
	if (vRetResult != null)
		iSearchResult = CPUMaint.getSearchCount();
	if (vRetResult == null && strErrMsg == null && WI.fillTextValue("trans_no").length()>0)
		strErrMsg = CPUMaint.getErrMsg();		
%>
<body bgcolor="#D2AE72" onLoad="FocusStuff();">
<form name="form_" action="component_transfer.jsp" method="post"  >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY MAINTENANCE - TRANSFER ITEM PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5"><font size="3" color="red">&nbsp;<%=WI.getStrValue(strErrMsg,"&nbsp;")%></font></td>
    </tr>
    <tr> 
      <td width="2%" height="30">&nbsp; <input type="text" name="area1" readonly="yes" size="2" style="background-color:#FFFFFF;border-width: 0px;"></td>
      <td width="17%"><strong>Transfer #</strong></td>
      <td width="20%" valign="middle">
			<%
				if(vTransferNo != null && vTransferNo.size() > 0)
					strTemp = (String)vTransferNo.elementAt(0);
				else
					strTemp = WI.fillTextValue("trans_no");
			 %>  
			 <input name="trans_no" type="text" size="16" maxlength="32"
	  value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td width="5%" valign="middle"><font size="1"><a href="javascript:SearchTransaction();"><img src="../../../images/search.gif" alt="search" border="0"></a></font></td>
      <td width="56%" valign="middle">&nbsp;</td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td colspan="4">NOTE: <br>
        1 . Enter the transfer number to create / edit.</td>
    </tr>
    <tr> 
      <td height="19" colspan="5"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td><strong>Property number </strong></td>
      <td height="29" valign="middle"> <%
      if (vEditInfo != null && vEditInfo.size()>0){
      	strTemp = WI.getStrValue((String)vEditInfo.elementAt(2),"");
	  }else{
      	strTemp = WI.fillTextValue("prop_no");
	  }
	  %> <input name="prop_no" type="text" size="16" maxlength="32"
	  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td height="29" valign="middle"><font size="1"> 
	  <a href="javascript:SearchComponent();">
        <img src="../../../images/search.gif" alt="search" border="0"> </a></font></td>
      <td height="29" valign="middle"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
  <% if (vPropDtls != null && vPropDtls.size()>0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="3%" height="26" bgcolor="#C78D8D">&nbsp;</td>
      <td colspan="4" bgcolor="#C78D8D"><strong><font color="#FFFFFF">PROPERTY 
        DETAILS</font></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="4"><u>PROPERTY DESCRIPTION</u></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">Description : <strong><%=(String)vPropDtls.elementAt(0)%></strong></td>
      <td width="38%">Category : <strong><%=WI.getStrValue((String)vPropDtls.elementAt(10),"Undefined")%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td width="30%">Property Number : <strong><%=WI.getStrValue((String)vPropDtls.elementAt(3),"Unknown")%></strong></td>
      <td width="26%">Serial Number : <strong><%=WI.getStrValue((String)vPropDtls.elementAt(4),"Unknown")%></strong></td>
      <td>Product Number : <strong><%=WI.getStrValue((String)vPropDtls.elementAt(5),"Unknown")%></strong></td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Warranty Until : <strong><%=WI.getStrValue((String)vPropDtls.elementAt(7),"Unknown")%></strong></td>
      <td>Status : <strong><%=WI.getStrValue((String)vPropDtls.elementAt(6),"Unknown")%></strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="4"><u>LOCATION</u></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td width="3%">&nbsp;</td>
      <td colspan="3"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> : <strong><%=WI.getStrValue((String)vPropDtls.elementAt(8),"&nbsp;")%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">Department : <strong><%=WI.getStrValue((String)vPropDtls.elementAt(9),"&nbsp;")%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">Laboratory/Stock Room : <strong><%=WI.getStrValue((String)vPropDtls.elementAt(1),"Unknown")%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">Building : <strong><%=WI.getStrValue((String)vPropDtls.elementAt(2),"Unknown")%></strong></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		
      <td width="3%">&nbsp;</td>
		<td width="16%">&nbsp;</td>
		<td width="30%">&nbsp;</td>
		
      <td width="51%">&nbsp;</td>
	</tr>
    <tr> 
      <td height="18" colspan="4"><hr size="1"></td>
    </tr>
    <tr bgcolor="#C78D8D"> 
      <td height="30" width="3%" >&nbsp;</td>
      <td colspan="3"><strong><font color="#FFFFFF">TRANSFER DETAILS</font></strong></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Transfer Date :</td>
      <td>
      <%
      if (vEditInfo != null && vEditInfo.size()>0)
    	  strTemp = WI.getStrValue((String)vEditInfo.elementAt(12),"");
	  else
	      strTemp = WI.fillTextValue("trans_date");%>
      <input name="trans_date" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
    <a href="javascript:show_calendar('form_.trans_date');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
      </td>
      <td width="51%" height="30" valign="middle">&nbsp;</td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Requested by :</td>
      <td >
      <%
      if (vEditInfo != null && vEditInfo.size()>0)
    	  strTemp = WI.getStrValue((String)vEditInfo.elementAt(18),"");
	  else
	      strTemp = WI.fillTextValue("transfer_by");%>
      <input name="transfer_by" type="text" class="textbox" size="32" maxlength="32" value="<%=strTemp%>">
      </td>
      <td><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" hspace="0" vspace="0" border="0"></a></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Reason:</td>
      <td colspan="2">
		<%
	      if (vEditInfo != null && vEditInfo.size()>0)
    		  strTemp = WI.getStrValue((String)vEditInfo.elementAt(19),"");
		  else
			strTemp = WI.fillTextValue("reason_index");%>
       <select name="reason_index">
                <option value="">N/A</option>
                <%=dbOP.loadCombo("trans_reason_index","reason"," from inv_preload_trans_reason order by reason", strTemp, false)%> </select>
        <font size="1"><a href='javascript:viewList("inv_preload_trans_reason","trans_reason_index","reason","TRANSFER REASON",
		"INV_TRANSFER_LOG","REASON","","","reason_index")'><img src="../../../images/update.gif" width="60" height="25" border="0"></a> 
        click to update list of REASONS</font></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Full Reason :</td>
      <td colspan="2">
      <%
      if (vEditInfo != null && vEditInfo.size()>0)
    	  strTemp = WI.getStrValue((String)vEditInfo.elementAt(15),"");
	  else
	      strTemp = WI.fillTextValue("reason");%>
      <textarea name="reason" cols="45" rows="3" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea>
      </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="2"><strong><u>TRANSFER TO :</u></strong></td>
      <td width="73%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <td width="22%"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> :</td>
      <td> <%
       if (vEditInfo != null && vEditInfo.size()>0)
    	  strTemp = WI.getStrValue((String)vEditInfo.elementAt(16),"");
	  else
	       strTemp = WI.fillTextValue("c_index");%> <select name="c_index" onChange="ReloadCollege();">
          <option value="0">N/A</option>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Department :</td>
      <td> <%
      if (vEditInfo != null && vEditInfo.size()>0)
    	  strTemp2 = WI.getStrValue((String)vEditInfo.elementAt(17),"");
	  else
      strTemp2 = WI.fillTextValue("d_index");%> <select name="d_index">
          <% if(strTemp!=null && strTemp.compareTo("0") !=0){%>
          <option value="">All</option>
          <%}  
if (strTemp == null || strTemp.length() == 0 || strTemp.compareTo("0") == 0) strTemp = " and (c_index = 0 or c_index is null) ";
	else strTemp = " and c_index = " +  strTemp;
%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 " + strTemp + " order by d_name asc",strTemp2, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Laboratory/Stock Room :</td>
      <td> <%
       if (vEditInfo != null && vEditInfo.size()>0)
    	  strTemp2 = WI.getStrValue((String)vEditInfo.elementAt(9),"");
	  else
       strTemp2 = WI.fillTextValue("room_idx");%> <select name="room_idx">
          <option value="">N/A</option>
          <%strTemp = " from E_ROOM_DETAIL where E_ROOM_DETAIL.is_del = 0 order by ROOM_NUMBER";%>
        <%=dbOP.loadCombo("ROOM_INDEX","ROOM_NUMBER", strTemp, strTemp2, false)%></select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Location Description : </td>
		 <%
       if (vEditInfo != null && vEditInfo.size()>0)
    	   strTemp = WI.getStrValue((String)vEditInfo.elementAt(9),"");
	  	 else
	       strTemp = WI.fillTextValue("loc_desc");%>						
      <td><input name="loc_desc" type="text" class="textbox" value="<%=strTemp%>" size="32" maxlength="64"
	   onFocus="style.backgroundColor='#D3EBFF'"onblur='style.backgroundColor="white"'></td>
    </tr>
    <tr> 
      <td colspan="3" height="51">&nbsp;
        <input type="text" name="area2" readonly="yes" size="2" style="background-color:#FFFFFF;border-width: 0px;"></td>
      <td > <font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'> <img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to add entry 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
        Click to edit entry <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to cancel 
        <%}%>
        </font></td>
    </tr>
  </table>
  <%}
  if (vRetResult!=null && vRetResult.size()>0) {%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="25" colspan="5" class="thinborder"><div align="center"> 
          <p><strong><font size="2">TRANSFER DETAILS</font></strong></p>
        </div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3" class="thinborder"><font size="1"><strong>TOTAL 
        ITEMS: &nbsp;&nbsp;<%=iSearchResult%></strong></font> <div align="right"></div></td>
      <td colspan="2" align="right" class="thinborder"><%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/CPUMaint.defSearchSize;
		if(iSearchResult % CPUMaint.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1){%>
        <select name="jumpto" onChange="ReloadPage();" style="font-size:11px">
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
        </select>
        <%} else {%>
&nbsp;
<%} //if no pages %></td>
    </tr>
    <tr> 
      <td width="11%" height="25" align="center" class="thinborder"><font size="1"><strong>PROPERTY 
        # </strong></font></td>
      <td width="29%" align="center" class="thinborder"><font size="1"><strong>ITEM 
        NAME/SERIAL #/PRODUCT #</strong></font></td>
      <td width="26%" align="center" class="thinborder"><font size="1"><strong>ORIGINAL 
        LOCATION/OWNER</strong></font></td>
      <td width="24%" align="center" class="thinborder"><font size="1"><strong>TRANSFER 
        LOCATION /OWNER</strong></font></td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>TRANSFER DATE </strong></font></td>
    </tr>
    <%for (i = 0; i< vRetResult.size(); i+=23){%>
    <tr> 
      <td class="thinborder" height="25"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td class="thinborder"> <font size="1">Item Name: <%=(String)vRetResult.elementAt(i+3)%> <%=WI.getStrValue((String)vRetResult.elementAt(i+4),"<br>Product No: ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"<br>Serial No: ","","")%> </font> </td>
      <td valign="top" class="thinborder"><font size="1"> <%=WI.getStrValue((String)vRetResult.elementAt(i+6),"Room: ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+7),"<br>Location: ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+19),"<br>College: ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+21),"<br>Department: ","","&nbsp;")%> </font></td>
      <td valign="top" class="thinborder"><font size="1"> <%=WI.getStrValue((String)vRetResult.elementAt(i+9),"Room: ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+10),"<br>Location: ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+20),"<br>College: ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+22),"<br>Department/office: ","","&nbsp;")%> </font></td>
      <td valign="top" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+13)%></font></td>
    </tr>
    <%}// end for loop%>
  </table>
  <%}// if vRetResult != null && vRetResult.size() > 0 %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
    <input type="hidden" name="page_action">
   	<input type="hidden" name="print_pg">
   	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
   	<input type="hidden" name="focus_area">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>