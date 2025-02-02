<%@ page language="java" import="utility.*, inventory.*, java.util.Vector"%>
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
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value= strAction;
	this.SubmitOnce("form_");
}
function ReloadPage()
{
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

function SearchProperty(){
	var pgLoc = "../comp_log/search_component.jsp?opner_info=form_.prop_num";
	var win=window.open(pgLoc,"SearchProperty",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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
								"INVENTORY-COMP_MAINTENANCE","component_stat_update.jsp");
	
	Vector vRetResult = null;
	Vector vEditInfo = null;
	Vector vCompInfo  = null;
	Vector vCPUParts  = null;

	int i = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strPrepareToEdit = null;
	String strPageAction = null;
	strPageAction = WI.fillTextValue("page_action");
	strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

	InventoryLog InvLog = new InventoryLog();
	InvCPUMaintenance InvMaint = new InvCPUMaintenance();

	if(strPrepareToEdit.equals("1")){
		vEditInfo = InvMaint.operateOnComponentStatus(dbOP, request, 3);
	}

	if (WI.fillTextValue("prop_num").length()>0)	{
		vCompInfo = InvLog.operateOnComponentsInv(dbOP,request,3);
//		System.out.println("vCompInfo " + vCompInfo);
		if (vCompInfo == null)	
			strErrMsg = InvLog.getErrMsg();
		else {
			if (strPageAction != null && strPageAction.length() > 0){
			   if(InvMaint.operateOnComponentStatus(dbOP, request, Integer.parseInt(strPageAction)) == null ){
				  strErrMsg = InvMaint.getErrMsg();
			   }else{
				  strPrepareToEdit = "0";
				  if(strPageAction.equals("1"))
				     strErrMsg = "Status Log successful.";	
 				  if(strPageAction.equals("2"))
				     strErrMsg = "Successfully edited remarks.";					
			   }
		   }		
		}
		vRetResult = InvMaint.operateOnComponentStatus(dbOP, request,4);			
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="component_stat_update.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY MAINTENANCE - ITEM STATUS UPDATE PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5">&nbsp;<font size="3" color="red"><%=WI.getStrValue(strErrMsg,"")%></font></td>
    </tr>
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td width="20%"><strong>Property number </strong></td>
      <td width="20%">
      <%strTemp = WI.fillTextValue("prop_num");%> 
      <input name="prop_num" type="text" size="16" maxlength="32" value="<%=strTemp%>" class="textbox" 
      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="9%"><font size="1"><a href="javascript:SearchProperty();"><img src="../../../images/search.gif" alt="search" border="0"></a></font></td>
      <td width="48%" align="left"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
	<%if (vCompInfo != null && vCompInfo.size()>0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="2%" height="26">&nbsp;</td>
      <td colspan="4" bgcolor="#C78D8D"><strong><font color="#FFFFFF">PROPERTY 
        DETAILS</font></strong></td>
    </tr>
    <tr> 
      <td width="2%" height="30">&nbsp;</td>
      <td colspan="4"><strong><u>PROPERTY DESCRIPTION</u></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td width="1%">&nbsp;</td>
      <td width="33%">Property Number :      
	  <%if (vCompInfo!=null && vCompInfo.size()>0)
	      	strTemp = WI.getStrValue((String)vCompInfo.elementAt(9),"0");
	  %>
        <strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></td>
      <td width="31%">
        <%if (vCompInfo!=null && vCompInfo.size()>0)
	      	strTemp = (String)vCompInfo.elementAt(10);
	  %>
        <strong><%=WI.getStrValue(strTemp,"Serial Number : ","","&nbsp;")%></strong></td>
      <td width="33%">
        <%if (vCompInfo!=null && vCompInfo.size()>0)
	      	strTemp = (String)vCompInfo.elementAt(11);
	  %>
        <strong><%=WI.getStrValue(strTemp,"Product Number : ","","&nbsp;")%></strong></td>
    </tr>
    <tr> 
      <td colspan="5"><hr size="1"></hr></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="30">&nbsp;</td>
      <td colspan="3"><strong><u>LOCATION</u></strong></td>
    </tr>
    <tr> 
      <td width="2%" height="26">&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <%
	  if (vCompInfo!=null && vCompInfo.size()>0)
	      	strTemp = (String)vCompInfo.elementAt(23);
	  %>
      <td width="14%" colspan="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td width="82%"><strong>: <%=WI.getStrValue(strTemp,"&nbsp;")%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <%if (vCompInfo!=null && vCompInfo.size()>0)
	      	strTemp = (String)vCompInfo.elementAt(24);
	  %>
      <td colspan="1">Department</td>
      <td><strong>: <%=WI.getStrValue(strTemp,"&nbsp;")%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <%if (vCompInfo!=null && vCompInfo.size()>0)
	      	strTemp = (String)vCompInfo.elementAt(25);
	  %>
      <td colspan="1">Building</td>
      <td><strong>: <%=WI.getStrValue(strTemp,"&nbsp;")%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <%if (vCompInfo!=null && vCompInfo.size()>0)
	      	strTemp = (String)vCompInfo.elementAt(26);
	  %>
      <td colspan="1">Room</td>
      <td><strong>: <%=WI.getStrValue(strTemp,"&nbsp;")%></strong></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#C78D8D"> 
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="3" height="25" valign="middle"><font color="#FFFFFF"><strong>STATUS 
        DETAILS</strong></font></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Current Status </td>
			<%
				if (vCompInfo!= null && vCompInfo.size()>0)
					strTemp = (String)vCompInfo.elementAt(22);
			%>			
      <td>: <%=strTemp%></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <td width="14%">Status</td>
      <td width="82%">:  
       <%strTemp = WI.fillTextValue("stat_index");%> 
			<select name="stat_index">
          <option value="">Select status</option>
          <%=dbOP.loadCombo("inv_stat_index","inv_status"," from inv_preload_status" + 
					" where is_default = 0 order by inv_status", strTemp, false)%> </select>
        <font size="1"><a href='javascript:viewList("inv_preload_status","inv_stat_index","inv_status","INVENTORY STATUS",
						"inv_item, inv_stat_update_log","inv_stat_index, status_fr",
						"and inv_item.is_valid = 1, and inv_stat_update_log.is_valid = 1","is_default = 0","stat_index")'><img src="../../../images/update.gif" border="0"></a>
        click to update STATUS list</font> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Remarks</td>
      <td>:
		<%
		if (vEditInfo!= null && vEditInfo.size()>0)
			strTemp = WI.getStrValue((String)vEditInfo.elementAt(9),"");
		else
			strTemp = WI.fillTextValue("remark");
		%> 
		<textarea name="remark" cols="45" rows="2" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" 
		nBlur="style.backgroundColor='white'" ><%=strTemp%></textarea>
		</td>
    </tr>
    <tr> 
      <td height="35" colspan="4"><div align="center"><font size="1"> 
          <%if(strPrepareToEdit.compareTo("1") != 0) {%>
          <a href='javascript:PageAction(1,"");'> <img src="../../../images/save.gif" border="0" name="hide_save"></a> 
          Click to add entry 
          <%}else{%>
          <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
          Click to edit entry <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
          Click to cancel 
          <%}%>
          </font></div></td>
    </tr>
  </table>
  <%if (vRetResult!=null && vRetResult.size()>0) {%>
 <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="25" colspan="6" class="thinborder"><div align="center"> 
          <p><strong><font size="2" color="#FFFFFF">STATUS UPDATE LOG</font></strong></p>
        </div></td>
    </tr>
    <tr> 
      <td height="26" class="thinborder" align="center" width="15%"><font size="1"><strong>UPDATE DATE</strong></font></td>
      <td class="thinborder" align="center" width="20%"><strong><font size="1">UPDATED BY</font></strong></td>
      <td class="thinborder" align="center" width="15%"><strong><font size="1">STATUS FROM</font></strong></td>
      <td class="thinborder" align="center" width="15%"><strong><font size="1">STATUS TO</font></strong></td>
      <td class="thinborder" align="center" width="25%"><strong><font size="1">REMARKS</font></strong></td>
      <td align="center" class="thinborder" width="10%">&nbsp; </td>
    </tr>
	<%for ( i = 0; i< vRetResult.size(); i+=10) {%>
    <tr> 
      <td height="25" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+6),(String)vRetResult.elementAt(i+7),(String)vRetResult.elementAt(i+8),1)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></font></td>
	  <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+5)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9),"")%></font></td>
      <td class="thinborder" align="center">
      <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
      </td>
    </tr>
    <%}%>
  </table>
<%		}//if result exists
	} //if item details are found%>
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
   	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>